import { pool } from "../../db/pool.js";
import { loadOfficialScoringRules } from "./loadRules.js";
import { computePredictionPoints } from "./rules.js";

export async function calculateMatchScores(matchId: number): Promise<void> {
  const matchResult = await pool.query("SELECT * FROM matches WHERE id = $1", [matchId]);
  const match = matchResult.rows[0];
  if (!match || match.status !== "FINISHED" || match.home_score == null || match.away_score == null) return;

  const rules = await loadOfficialScoringRules();
  const predictions = await pool.query("SELECT * FROM predictions WHERE match_id = $1", [matchId]);

  for (const prediction of predictions.rows) {
    const computed = computePredictionPoints({
      predictedHome: prediction.predicted_home_score,
      predictedAway: prediction.predicted_away_score,
      realHome: match.home_score,
      realAway: match.away_score,
      roundKey: match.round_key,
      stage: match.stage,
      roundLabel: match.round_label,
      predictedAdvancingTeamId: prediction.predicted_advancing_team_id,
      winnerTeamId: match.winner_team_id,
      rules
    });

    await pool.query(
      `INSERT INTO prediction_scores (user_id, source_type, source_id, points, breakdown)
      VALUES ($1, 'MATCH', $2, $3, $4::jsonb)
      ON CONFLICT (user_id, source_type, source_id)
      DO UPDATE SET points = EXCLUDED.points, breakdown = EXCLUDED.breakdown, updated_at = NOW()`,
      [prediction.user_id, matchId, computed.points, JSON.stringify(computed.breakdown)]
    );
  }
}
