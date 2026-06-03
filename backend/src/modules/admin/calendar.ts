import { Router } from "express";
import { z } from "zod";
import { pool } from "../../db/pool.js";
import { requireAdmin, requireAuth } from "../../middlewares/auth.js";
import { matchCalendarDateSql } from "../matches/calendarDate.js";
import { activeTournamentCondition, matchFromClause, matchSelectFields } from "../matches/query.js";
import {
  buildPredictionAvailability,
  getActiveTournamentId,
  resolvePredictionLockAt
} from "../settings/service.js";
import { previewMatchPoints } from "../scoring/preview.js";
import { syncAllOfficialKnockoutAdvancement } from "../bracket/knockoutAdvancement.js";

const calendarSchema = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/)
});

const previewSchema = z.object({
  matchId: z.coerce.number().int().positive(),
  predictedHomeScore: z.coerce.number().int().min(0),
  predictedAwayScore: z.coerce.number().int().min(0),
  realHomeScore: z.coerce.number().int().min(0),
  realAwayScore: z.coerce.number().int().min(0)
});

export const adminCalendarRouter = Router();
adminCalendarRouter.use(requireAuth, requireAdmin);

async function mapCalendarRows(rows: Awaited<ReturnType<typeof pool.query>>["rows"]) {
  return Promise.all(
    rows.map(async (row) => {
      const lockAt = await resolvePredictionLockAt(row);
      return {
        id: row.id,
        stage: row.stage,
        roundKey: row.round_key,
        status: row.status,
        startsAt: row.starts_at,
        roundLabel: row.round_label,
        matchday: row.matchday,
        groupName: row.group_name,
        homeTeamId: Number(row.home_team_id),
        homeTeamName: row.home_team_name,
        homeTeamLogoUrl: row.home_team_logo_url,
        awayTeamId: Number(row.away_team_id),
        awayTeamName: row.away_team_name,
        awayTeamLogoUrl: row.away_team_logo_url,
        homeScore: row.home_score,
        awayScore: row.away_score,
        ...(await buildPredictionAvailability(row, lockAt)),
        predictionLockAt: lockAt.toISOString()
      };
    })
  );
}

const knockoutRoundOrderSql = `CASE m.round_key
  WHEN 'R16' THEN 1
  WHEN 'R8' THEN 2
  WHEN 'R4' THEN 3
  WHEN 'SF' THEN 4
  WHEN 'TP3' THEN 5
  WHEN 'F' THEN 6
  ELSE 99
END`;

adminCalendarRouter.get("/calendar/knockout", async (_req, res, next) => {
  try {
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId) {
      res.json({ matches: [] });
      return;
    }

    let result = await pool.query(
      `SELECT ${matchSelectFields}
      ${matchFromClause}
      WHERE ${activeTournamentCondition("m", 1)} AND m.stage = 'KNOCKOUT'
      ORDER BY ${knockoutRoundOrderSql}, m.starts_at ASC`,
      [tournamentId]
    );

    if (result.rows.length > 0) {
      await syncAllOfficialKnockoutAdvancement(tournamentId);
      result = await pool.query(
        `SELECT ${matchSelectFields}
        ${matchFromClause}
        WHERE ${activeTournamentCondition("m", 1)} AND m.stage = 'KNOCKOUT'
        ORDER BY ${knockoutRoundOrderSql}, m.starts_at ASC`,
        [tournamentId]
      );
    }

    res.json({ matches: await mapCalendarRows(result.rows) });
  } catch (error) {
    next(error);
  }
});

adminCalendarRouter.get("/calendar", async (req, res, next) => {
  try {
    const { date } = calendarSchema.parse(req.query);
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId) {
      res.json({ date, matches: [] });
      return;
    }

    const result = await pool.query(
      `SELECT ${matchSelectFields}
      ${matchFromClause}
      WHERE ${activeTournamentCondition("m", 1)}
        AND m.stage = 'GROUP'
        AND ${matchCalendarDateSql("m")} = $2::date
      ORDER BY m.matchday ASC NULLS LAST, m.starts_at ASC`,
      [tournamentId, date]
    );

    res.json({ date, matches: await mapCalendarRows(result.rows) });
  } catch (error) {
    next(error);
  }
});

adminCalendarRouter.post("/preview-points", async (req, res, next) => {
  try {
    const input = previewSchema.parse(req.body);
    const computed = await previewMatchPoints({
      matchId: input.matchId,
      predictedHome: input.predictedHomeScore,
      predictedAway: input.predictedAwayScore,
      realHome: input.realHomeScore,
      realAway: input.realAwayScore
    });
    res.json(computed);
  } catch (error) {
    next(error);
  }
});
