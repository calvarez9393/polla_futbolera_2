import { Router } from "express";
import { z } from "zod";
import { pool } from "../../db/pool.js";
import {
  getActiveTournamentId,
  isMatchAcceptingPredictions,
  loadKnockoutPredictionConfig,
  resolvePredictionLockAt
} from "../settings/service.js";
import { getOfficialR16Bracket } from "../bracket/r16Service.js";
import { matchCalendarDateSql } from "./calendarDate.js";
import { activeTournamentCondition, matchFromClause, matchSelectFields } from "./query.js";

export const matchesRouter = Router();

const listSchema = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  stage: z.enum(["GROUP", "KNOCKOUT"]).optional(),
  groupId: z.coerce.number().int().positive().optional()
});

matchesRouter.get("/dates", async (_req, res, next) => {
  try {
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId) {
      res.json([]);
      return;
    }
    const calDate = matchCalendarDateSql("matches");
    const result = await pool.query(
      `SELECT ${calDate} AS match_date, COUNT(*)::int AS match_count
      FROM matches
      WHERE tournament_id = $1
      GROUP BY ${calDate}
      ORDER BY match_date`,
      [tournamentId]
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
});

matchesRouter.get("/", async (req, res, next) => {
  try {
    const filters = listSchema.parse(req.query);
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId) {
      res.json([]);
      return;
    }

    const conditions: string[] = [activeTournamentCondition("m", 1)];
    const params: unknown[] = [tournamentId];

    if (filters.date) {
      params.push(filters.date);
      conditions.push(`${matchCalendarDateSql("m")} = $${params.length}::date`);
    }
    if (filters.stage) {
      params.push(filters.stage);
      conditions.push(`m.stage = $${params.length}`);
    }
    if (filters.groupId) {
      params.push(filters.groupId);
      conditions.push(`m.group_id = $${params.length}`);
    }

    const where = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";

    const result = await pool.query(
      `SELECT ${matchSelectFields}
      ${matchFromClause}
      ${where}
      ORDER BY m.starts_at ASC`,
      params
    );

    const knockoutConfig = result.rows.some((row) => row.stage === "KNOCKOUT")
      ? await loadKnockoutPredictionConfig()
      : null;

    const enriched = await Promise.all(
      result.rows.map(async (row) => {
        const lockAt = await resolvePredictionLockAt(row);
        return {
          ...row,
          prediction_lock_at_computed: lockAt.toISOString(),
          predictions_open: isMatchAcceptingPredictions(row, lockAt, new Date(), knockoutConfig)
        };
      })
    );

    res.json(enriched);
  } catch (error) {
    next(error);
  }
});

matchesRouter.get("/r16-bracket", async (_req, res, next) => {
  try {
    res.json(await getOfficialR16Bracket());
  } catch (error) {
    next(error);
  }
});

matchesRouter.get("/:id", async (req, res, next) => {
  try {
    if (req.params.id === "dates") return next();

    const result = await pool.query(
      `SELECT ${matchSelectFields}
      ${matchFromClause}
      WHERE m.id = $1`,
      [req.params.id]
    );
    if (!result.rows[0]) {
      res.status(404).json({ message: "Partido no encontrado" });
      return;
    }
    const row = result.rows[0];
    const lockAt = await resolvePredictionLockAt(row);
    const knockoutConfig =
      row.stage === "KNOCKOUT" ? await loadKnockoutPredictionConfig() : null;
    res.json({
      ...row,
      prediction_lock_at_computed: lockAt.toISOString(),
      predictions_open: isMatchAcceptingPredictions(row, lockAt, new Date(), knockoutConfig)
    });
  } catch (error) {
    next(error);
  }
});
