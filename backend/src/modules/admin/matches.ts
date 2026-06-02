import { Router } from "express";
import { z } from "zod";
import { pool } from "../../db/pool.js";
import { requireAdmin, requireAuth } from "../../middlewares/auth.js";
import { finalizeMatch } from "../scoring/finalize.js";
import { getSetting, setSetting, getPredictionLockHours } from "../settings/service.js";
import { getKnockoutFixtureDefaults } from "../bracket/knockoutPredictionWindow.js";
import { importWorldCup2026Schedule } from "../import/worldCup2026.js";
import { optionalTeamId } from "../../utils/zodHelpers.js";

const matchBodySchema = z.object({
  homeTeamId: z.number().int().positive(),
  awayTeamId: z.number().int().positive(),
  startsAt: z.string().datetime(),
  stage: z.enum(["GROUP", "KNOCKOUT"]).default("GROUP"),
  groupId: z.number().int().positive().optional(),
  roundLabel: z.string().optional(),
  matchday: z.number().int().min(1).max(10).optional(),
  predictionLockAt: z.string().datetime().optional(),
  status: z.enum(["NOT_STARTED", "LIVE", "FINISHED"]).default("NOT_STARTED"),
  homeScore: z.number().int().min(0).nullable().optional(),
  awayScore: z.number().int().min(0).nullable().optional()
});

const bulkSchema = z.object({
  matches: z.array(matchBodySchema).min(1)
});

const optionalDateYmd = z.union([z.string().regex(/^\d{4}-\d{2}-\d{2}$/), z.literal("")]);

const settingsSchema = z
  .object({
    predictionLockHoursBefore: z.number().int().min(0).max(168),
    tournamentName: z.string().min(1).optional(),
    knockoutPredictionsOpenDate: optionalDateYmd.optional(),
    knockoutPredictionsCloseDate: optionalDateYmd.optional()
  })
  .refine(
    (data) => {
      const open = data.knockoutPredictionsOpenDate?.trim();
      const close = data.knockoutPredictionsCloseDate?.trim();
      if (!open || !close) return true;
      return open <= close;
    },
    { message: "La fecha de apertura debe ser anterior o igual a la de cierre" }
  );

export const adminMatchesRouter = Router();
adminMatchesRouter.use(requireAuth, requireAdmin);

adminMatchesRouter.get("/settings/tournament", async (_req, res, next) => {
  try {
    const fixtureDefaults = getKnockoutFixtureDefaults();
    res.json({
      tournamentName: await getSetting("tournament_name", "Mundial FIFA 2026"),
      tournamentSeason: await getSetting("tournament_season", "2026"),
      predictionLockHoursBefore: await getPredictionLockHours(),
      dataSource: await getSetting("data_source", "manual"),
      knockoutPredictionsOpenDate: await getSetting("knockout_predictions_open_date", ""),
      knockoutPredictionsCloseDate: await getSetting("knockout_predictions_close_date", ""),
      knockoutFixtureDefaults: fixtureDefaults
    });
  } catch (error) {
    next(error);
  }
});

adminMatchesRouter.put("/settings/tournament", async (req, res, next) => {
  try {
    const input = settingsSchema.parse(req.body);
    if (input.tournamentName) await setSetting("tournament_name", input.tournamentName);
    await setSetting("prediction_lock_hours_before", String(input.predictionLockHoursBefore));
    if (input.knockoutPredictionsOpenDate !== undefined) {
      await setSetting("knockout_predictions_open_date", input.knockoutPredictionsOpenDate.trim());
    }
    if (input.knockoutPredictionsCloseDate !== undefined) {
      await setSetting(
        "knockout_predictions_close_date",
        input.knockoutPredictionsCloseDate.trim()
      );
    }
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

adminMatchesRouter.post("/matches", async (req, res, next) => {
  try {
    const input = matchBodySchema.parse(req.body);
    const tournament = await pool.query("SELECT id FROM tournaments ORDER BY id LIMIT 1");
    const tournamentId = tournament.rows[0]?.id ?? null;

    const result = await pool.query(
      `INSERT INTO matches
        (external_id, tournament_id, group_id, stage, status, starts_at, round_label, matchday,
         prediction_lock_at, home_team_id, away_team_id, home_score, away_score)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
      RETURNING *`,
      [
        `manual-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
        tournamentId,
        input.groupId ?? null,
        input.stage,
        input.status,
        input.startsAt,
        input.roundLabel ?? null,
        input.matchday ?? null,
        input.predictionLockAt ?? null,
        input.homeTeamId,
        input.awayTeamId,
        input.homeScore ?? null,
        input.awayScore ?? null
      ]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
});

adminMatchesRouter.post("/matches/bulk", async (req, res, next) => {
  try {
    const input = bulkSchema.parse(req.body);
    let created = 0;
    for (const match of input.matches) {
      await pool.query(
        `INSERT INTO matches
          (external_id, tournament_id, group_id, stage, status, starts_at, round_label, matchday,
           prediction_lock_at, home_team_id, away_team_id, home_score, away_score)
        VALUES ($1,(SELECT id FROM tournaments ORDER BY id LIMIT 1),$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)`,
        [
          `manual-bulk-${Date.now()}-${created}`,
          match.groupId ?? null,
          match.stage,
          match.status,
          match.startsAt,
          match.roundLabel ?? null,
          match.matchday ?? null,
          match.predictionLockAt ?? null,
          match.homeTeamId,
          match.awayTeamId,
          match.homeScore ?? null,
          match.awayScore ?? null
        ]
      );
      created += 1;
    }
    res.status(201).json({ created });
  } catch (error) {
    next(error);
  }
});

adminMatchesRouter.post("/matches/import-worldcup-2026", async (_req, res, next) => {
  try {
    const result = await importWorldCup2026Schedule();
    res.json(result);
  } catch (error) {
    next(error);
  }
});

adminMatchesRouter.patch("/matches/:id/result", async (req, res, next) => {
  try {
    const input = z
      .object({
        status: z.enum(["NOT_STARTED", "LIVE", "FINISHED"]),
        home_score: z.coerce.number().int().min(0).nullable(),
        away_score: z.coerce.number().int().min(0).nullable(),
        winner_team_id: optionalTeamId
      })
      .parse(req.body);

    const result = await pool.query(
      `UPDATE matches SET
        status = $1, home_score = $2, away_score = $3, winner_team_id = $4, updated_at = NOW()
      WHERE id = $5
      RETURNING *`,
      [input.status, input.home_score, input.away_score, input.winner_team_id, req.params.id]
    );

    if (!result.rows[0]) {
      res.status(404).json({ message: "Partido no encontrado" });
      return;
    }

    if (input.status === "FINISHED") {
      const m = result.rows[0];
      const isKnockout = m.stage === "KNOCKOUT";
      const isDraw =
        input.home_score != null &&
        input.away_score != null &&
        input.home_score === input.away_score;

      if (isKnockout && isDraw && !input.winner_team_id) {
        res.status(400).json({
          message:
            "En empate debes indicar el ganador en penales (quién pasa a la siguiente ronda)"
        });
        return;
      }

      let winnerId = input.winner_team_id ?? null;
      if (
        winnerId == null &&
        input.home_score != null &&
        input.away_score != null &&
        input.home_score !== input.away_score
      ) {
        winnerId =
          input.home_score > input.away_score ? m.home_team_id : m.away_team_id;
      }
      if (winnerId) {
        await pool.query(`UPDATE matches SET winner_team_id = $1 WHERE id = $2`, [
          winnerId,
          req.params.id
        ]);
        result.rows[0].winner_team_id = winnerId;
      }
      await finalizeMatch(Number(req.params.id));
    }

    res.json({
      match: result.rows[0],
      message:
        result.rows[0].stage === "KNOCKOUT"
          ? "Partido actualizado. Ganador enviado a la siguiente ronda del cuadro oficial."
          : "Partido actualizado. Puntos y tabla de grupo recalculados."
    });
  } catch (error) {
    next(error);
  }
});
