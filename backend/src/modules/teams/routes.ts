import { Router } from "express";
import { pool } from "../../db/pool.js";
import { getActiveTournamentId } from "../settings/service.js";

export const teamsRouter = Router();

teamsRouter.get("/", async (_req, res, next) => {
  try {
    const result = await pool.query("SELECT id, name, short_name, logo_url FROM teams ORDER BY name");
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
});

teamsRouter.get("/groups", async (_req, res, next) => {
  try {
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId) {
      res.json([]);
      return;
    }
    const result = await pool.query(
      `SELECT g.id, g.name,
        (SELECT COUNT(*)::int FROM matches m WHERE m.group_id = g.id) AS match_count
      FROM groups g
      WHERE g.tournament_id = $1
      ORDER BY g.name`,
      [tournamentId]
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
});
