import { pool } from "../../db/pool.js";
import { sameKnockoutMatchup } from "../bracket/knockoutMatchup.js";
import { getTbdTeamId } from "../bracket/knockoutAdvancement.js";
import { resolveKnockoutAdvancingWithResolvedTeams } from "../bracket/knockoutAdvancingResolve.js";
import { getUserBracketTeamsForScoring } from "../bracket/resolveUserSlotTeams.js";
import { loadOfficialScoringRules } from "./loadRules.js";
import { computeAdvanceOnlyPoints, computePredictionPoints } from "./rules.js";
import type { OfficialScoringRules } from "./rulesConfig.js";

const WRONG_MATCHUP_BREAKDOWN = { wrongMatchup: 0 };

interface ScoredPoints {
  points: number;
  breakdown: Record<string, number>;
}

/**
 * Aplica el factor multiplicador del partido a los puntos calculados. Escala cada
 * componente del desglose (que siempre suma el total) para que las fichas de puntos y
 * el total sigan siendo coherentes. Con factor 1 devuelve los puntos sin tocar.
 */
function applyScoreMultiplier(scored: ScoredPoints, multiplier: number): ScoredPoints {
  if (Number.isFinite(multiplier) && multiplier !== 1) {
    const breakdown: Record<string, number> = {};
    for (const [key, value] of Object.entries(scored.breakdown)) {
      breakdown[key] = Math.round(value * multiplier);
    }
    const points = Object.values(breakdown).reduce((sum, value) => sum + value, 0);
    return { points, breakdown };
  }
  return scored;
}

async function scoreKnockoutPrediction(
  match: Record<string, any>,
  prediction: Record<string, any>,
  officialWinnerId: number | null,
  tbdId: number,
  rules: OfficialScoringRules
): Promise<ScoredPoints> {
  const officialHome = Number(match.home_team_id);
  const officialAway = Number(match.away_team_id);

  const userTeams = await getUserBracketTeamsForScoring(
    prediction.user_id as number,
    {
      id: Number(match.id),
      external_id: match.external_id as string,
      stage: match.stage as string,
      round_key: match.round_key as string,
      home_team_id: officialHome,
      away_team_id: officialAway,
      tournament_id: match.tournament_id as number
    },
    {
      bracket_home_team_id: prediction.bracket_home_team_id,
      bracket_away_team_id: prediction.bracket_away_team_id
    }
  );
  if (!userTeams) {
    // Sin cruce resoluble: solo puede puntuar el avance con su elegido explícito.
    const advanceOnly = computeAdvanceOnlyPoints({
      roundKey: match.round_key,
      stage: match.stage,
      roundLabel: match.round_label,
      predictedAdvancingTeamId:
        prediction.predicted_advancing_team_id != null
          ? Number(prediction.predicted_advancing_team_id)
          : null,
      winnerTeamId: officialWinnerId,
      rules
    });
    return advanceOnly ?? { points: 0, breakdown: WRONG_MATCHUP_BREAKDOWN };
  }

  const predictedAdvancingTeamId = resolveKnockoutAdvancingWithResolvedTeams(
    prediction.predicted_home_score as number,
    prediction.predicted_away_score as number,
    prediction.predicted_advancing_team_id,
    userTeams.homeTeamId,
    userTeams.awayTeamId,
    tbdId
  );

  if (
    sameKnockoutMatchup(userTeams.homeTeamId, userTeams.awayTeamId, officialHome, officialAway, tbdId)
  ) {
    return computePredictionPoints({
      predictedHome: prediction.predicted_home_score,
      predictedAway: prediction.predicted_away_score,
      realHome: match.home_score,
      realAway: match.away_score,
      roundKey: match.round_key,
      stage: match.stage,
      roundLabel: match.round_label,
      predictedAdvancingTeamId,
      winnerTeamId: officialWinnerId,
      rules
    });
  }

  // Cruce distinto al oficial: solo puntúa el avance si su elegido es quien realmente pasó.
  const advanceOnly = computeAdvanceOnlyPoints({
    roundKey: match.round_key,
    stage: match.stage,
    roundLabel: match.round_label,
    predictedAdvancingTeamId,
    winnerTeamId: officialWinnerId,
    rules
  });
  return advanceOnly ?? { points: 0, breakdown: WRONG_MATCHUP_BREAKDOWN };
}

export async function calculateMatchScores(matchId: number): Promise<void> {
  const matchResult = await pool.query("SELECT * FROM matches WHERE id = $1", [matchId]);
  const match = matchResult.rows[0];
  if (!match || match.status !== "FINISHED" || match.home_score == null || match.away_score == null) {
    return;
  }

  const rules = await loadOfficialScoringRules();
  const predictions = await pool.query(
    `SELECT * FROM predictions WHERE match_id = $1`,
    [matchId]
  );

  const isKnockout = match.stage === "KNOCKOUT";
  const tbdId = isKnockout ? await getTbdTeamId() : null;
  const multiplier = Number(match.score_multiplier ?? 1) || 1;

  let officialWinnerId = match.winner_team_id != null ? Number(match.winner_team_id) : null;
  if (isKnockout && !officialWinnerId && match.home_score !== match.away_score) {
    officialWinnerId =
      match.home_score > match.away_score
        ? Number(match.home_team_id)
        : Number(match.away_team_id);
  }

  for (const prediction of predictions.rows) {
    const baseScored: ScoredPoints =
      isKnockout && tbdId != null
        ? await scoreKnockoutPrediction(match, prediction, officialWinnerId, tbdId, rules)
        : computePredictionPoints({
            predictedHome: prediction.predicted_home_score,
            predictedAway: prediction.predicted_away_score,
            realHome: match.home_score,
            realAway: match.away_score,
            roundKey: match.round_key,
            stage: match.stage,
            roundLabel: match.round_label,
            predictedAdvancingTeamId: prediction.predicted_advancing_team_id,
            winnerTeamId: officialWinnerId,
            rules
          });
    const scored = applyScoreMultiplier(baseScored, multiplier);

    await pool.query(
      `INSERT INTO prediction_scores (user_id, source_type, source_id, points, breakdown)
      VALUES ($1, 'MATCH', $2, $3, $4::jsonb)
      ON CONFLICT (user_id, source_type, source_id)
      DO UPDATE SET points = EXCLUDED.points, breakdown = EXCLUDED.breakdown, updated_at = NOW()`,
      [prediction.user_id, matchId, scored.points, JSON.stringify(scored.breakdown)]
    );
  }
}
