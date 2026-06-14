import { pool } from "../../db/pool.js";

export interface LeaderboardRow {
  user_id: number;
  email: string;
  display_name: string | null;
  amount_paid: number;
  total_points: number;
  exact_scores: number;
  qualified_correct: number;
  knockout_advancing: number;
  late_stage_points: number;
}

export async function fetchLeaderboard(includeAllRoles = false): Promise<LeaderboardRow[]> {
  const roleFilter = includeAllRoles
    ? "WHERE u.is_active = TRUE"
    : "WHERE u.role = 'USER' AND u.is_active = TRUE";

  const result = await pool.query(
    `SELECT
      u.id AS user_id,
      u.email,
      u.display_name,
      COALESCE(u.amount_paid, 0)::int AS amount_paid,
      COALESCE(SUM(ps.points), 0)::int AS total_points,
      (
        SELECT COUNT(*)::int
        FROM predictions p
        JOIN matches m ON m.id = p.match_id
        WHERE p.user_id = u.id
          AND m.status = 'FINISHED'
          AND m.home_score IS NOT NULL
          AND p.predicted_home_score = m.home_score
          AND p.predicted_away_score = m.away_score
      ) AS exact_scores,
      COALESCE(
        (
          SELECT (psq.breakdown->>'correctCount')::int
          FROM prediction_scores psq
          WHERE psq.user_id = u.id AND psq.source_type = 'QUALIFIERS' AND psq.source_id = 0
        ),
        0
      ) AS qualified_correct,
      (
        SELECT COUNT(*)::int
        FROM predictions p
        JOIN matches m ON m.id = p.match_id
        WHERE p.user_id = u.id
          AND m.status = 'FINISHED'
          AND m.winner_team_id IS NOT NULL
          AND p.predicted_advancing_team_id = m.winner_team_id
          AND m.round_key IN ('R8', 'R4', 'SF', 'F', 'TP3')
      ) AS knockout_advancing,
      COALESCE(
        (
          SELECT SUM(ps2.points)::int
          FROM prediction_scores ps2
          JOIN matches m2 ON m2.id = ps2.source_id AND ps2.source_type = 'MATCH'
          WHERE ps2.user_id = u.id
            AND m2.round_key IN ('SF', 'F')
        ),
        0
      ) AS late_stage_points
    FROM users u
    LEFT JOIN prediction_scores ps ON ps.user_id = u.id
    ${roleFilter}
    GROUP BY u.id, u.email, u.display_name, u.amount_paid
    ORDER BY
      total_points DESC,
      exact_scores DESC,
      qualified_correct DESC,
      knockout_advancing DESC,
      late_stage_points DESC,
      u.email ASC`
  );

  return result.rows.map((row) => ({
    user_id: Number(row.user_id),
    email: row.email,
    display_name: row.display_name,
    amount_paid: Number(row.amount_paid),
    total_points: Number(row.total_points),
    exact_scores: Number(row.exact_scores),
    qualified_correct: Number(row.qualified_correct),
    knockout_advancing: Number(row.knockout_advancing),
    late_stage_points: Number(row.late_stage_points)
  }));
}
