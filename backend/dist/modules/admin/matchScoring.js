import { Router } from "express";
import { z } from "zod";
import { pool } from "../../db/pool.js";
import { requireAdmin, requireAuth } from "../../middlewares/auth.js";
import { matchSelectFields, matchFromClause } from "../matches/query.js";
export const adminMatchScoringRouter = Router();
adminMatchScoringRouter.use(requireAuth, requireAdmin);
adminMatchScoringRouter.get("/matches/:id/scoring", async (req, res, next) => {
    try {
        const matchId = z.coerce.number().int().positive().parse(req.params.id);
        const matchResult = await pool.query(`SELECT ${matchSelectFields}
      ${matchFromClause}
      WHERE m.id = $1`, [matchId]);
        const match = matchResult.rows[0];
        if (!match) {
            res.status(404).json({ message: "Partido no encontrado" });
            return;
        }
        const rows = await pool.query(`SELECT
        u.id AS user_id,
        u.email,
        u.display_name,
        p.predicted_home_score,
        p.predicted_away_score,
        p.predicted_advancing_team_id,
        ps.points,
        ps.breakdown
      FROM predictions p
      JOIN users u ON u.id = p.user_id
      LEFT JOIN prediction_scores ps
        ON ps.user_id = p.user_id AND ps.source_type = 'MATCH' AND ps.source_id = p.match_id
      WHERE p.match_id = $1
      ORDER BY ps.points DESC NULLS LAST, u.display_name, u.email`, [matchId]);
        const withoutPrediction = await pool.query(`SELECT u.id AS user_id, u.email, u.display_name
      FROM users u
      WHERE u.role IN ('USER', 'ADMIN')
        AND NOT EXISTS (SELECT 1 FROM predictions p WHERE p.user_id = u.id AND p.match_id = $1)
      ORDER BY u.display_name, u.email`, [matchId]);
        res.json({
            match: {
                id: match.id,
                status: match.status,
                homeTeamName: match.home_team_name,
                awayTeamName: match.away_team_name,
                homeScore: match.home_score,
                awayScore: match.away_score,
                groupName: match.group_name,
                roundLabel: match.round_label
            },
            participants: rows.rows.map((r) => ({
                userId: r.user_id,
                email: r.email,
                displayName: r.display_name,
                predictedHomeScore: r.predicted_home_score,
                predictedAwayScore: r.predicted_away_score,
                predictedAdvancingTeamId: r.predicted_advancing_team_id,
                points: r.points ?? 0,
                breakdown: r.breakdown ?? {}
            })),
            withoutPrediction: withoutPrediction.rows
        });
    }
    catch (error) {
        next(error);
    }
});
