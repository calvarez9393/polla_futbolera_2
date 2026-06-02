import { Router } from "express";
import { pool } from "../../db/pool.js";
import { getActiveTournamentId } from "../settings/service.js";
export const standingsRouter = Router();
standingsRouter.get("/", async (_req, res, next) => {
    try {
        const tournamentId = await getActiveTournamentId();
        if (!tournamentId) {
            res.json([]);
            return;
        }
        const result = await pool.query(`SELECT
        s.group_id, g.name AS group_name, s.team_id, t.name AS team_name, t.logo_url AS team_logo_url,
        s.rank, s.points, s.played, s.won, s.draw, s.lost, s.goals_for, s.goals_against, s.goal_diff
      FROM standings s
      JOIN groups g ON g.id = s.group_id
      JOIN teams t ON t.id = s.team_id
      WHERE s.tournament_id = $1
      ORDER BY g.name, s.rank`, [tournamentId]);
        res.json(result.rows);
    }
    catch (error) {
        next(error);
    }
});
