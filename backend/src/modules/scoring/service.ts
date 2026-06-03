import { pool } from "../../db/pool.js";
import { sameKnockoutMatchup } from "../bracket/knockoutMatchup.js";
import { getTbdTeamId } from "../bracket/knockoutAdvancement.js";
import { resolveKnockoutAdvancingWithResolvedTeams } from "../bracket/knockoutAdvancingResolve.js";
import { getUserBracketTeamsForScoring } from "../bracket/resolveUserSlotTeams.js";
import { loadOfficialScoringRules } from "./loadRules.js";
import { computePredictionPoints } from "./rules.js";

const WRONG_MATCHUP_BREAKDOWN = { wrongMatchup: 0 };

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

  const officialHome = Number(match.home_team_id);
  const officialAway = Number(match.away_team_id);

  let officialWinnerId = match.winner_team_id as number | null;
  if (isKnockout && !officialWinnerId && match.home_score !== match.away_score) {
    officialWinnerId =
      match.home_score > match.away_score ? officialHome : officialAway;
  }

  for (const prediction of predictions.rows) {
    let points = 0;
    let breakdown: Record<string, number> = WRONG_MATCHUP_BREAKDOWN;

    if (isKnockout && tbdId != null) {
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

      if (
        userTeams &&
        sameKnockoutMatchup(
          userTeams.homeTeamId,
          userTeams.awayTeamId,
          officialHome,
          officialAway,
          tbdId
        )
      ) {
        const predictedAdvancingTeamId = resolveKnockoutAdvancingWithResolvedTeams(
          prediction.predicted_home_score as number,
          prediction.predicted_away_score as number,
          prediction.predicted_advancing_team_id,
          userTeams.homeTeamId,
          userTeams.awayTeamId,
          tbdId
        );

        const computed = computePredictionPoints({
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
        points = computed.points;
        breakdown = computed.breakdown;
      }
    } else {
      const computed = computePredictionPoints({
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
      points = computed.points;
      breakdown = computed.breakdown;
    }

    await pool.query(
      `INSERT INTO prediction_scores (user_id, source_type, source_id, points, breakdown)
      VALUES ($1, 'MATCH', $2, $3, $4::jsonb)
      ON CONFLICT (user_id, source_type, source_id)
      DO UPDATE SET points = EXCLUDED.points, breakdown = EXCLUDED.breakdown, updated_at = NOW()`,
      [prediction.user_id, matchId, points, JSON.stringify(breakdown)]
    );
  }
}
