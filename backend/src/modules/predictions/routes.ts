import { Router } from "express";
import { z } from "zod";
import { pool } from "../../db/pool.js";
import { requireAuth } from "../../middlewares/auth.js";
import { matchCalendarDateSql } from "../matches/calendarDate.js";
import { activeTournamentCondition, matchFromClause, matchSelectFields } from "../matches/query.js";
import {
  buildPredictionAvailability,
  getActiveTournamentId,
  getSetting,
  loadKnockoutPredictionConfig,
  knockoutPredictionClosedReason,
  resolvePredictionLockAt
} from "../settings/service.js";
import {
  buildKnockoutPredictionWindowApi,
  formatVenueCalendarDate
} from "../bracket/knockoutPredictionWindow.js";
import { optionalTeamId } from "../../utils/zodHelpers.js";

const predictionSchema = z.object({
  matchId: z.coerce.number().int().positive(),
  predictedHomeScore: z.coerce.number().int().min(0),
  predictedAwayScore: z.coerce.number().int().min(0),
  predictedAdvancingTeamId: optionalTeamId
});

import {
  applyResolvedTeamsToMatchRows,
  enrichKnockoutAdvancingOnRows,
  syncAllOfficialKnockoutAdvancement
} from "../bracket/knockoutAdvancement.js";
import { resolveKnockoutAdvancingForSave } from "../bracket/knockoutAdvancingSave.js";
import { resolveUserSlotTeamsForMatch, predictionBracketJoinClause, predictionBracketSelectFields } from "../bracket/resolveUserSlotTeams.js";
import { mapCalendarMatchRow } from "./mapCalendarMatch.js";
import { syncUserBonusPicksFromBracket } from "../bracket/deriveBonusFromBracket.js";
import { requiresKnockoutAdvancingTeam } from "../scoring/rulesConfig.js";
import {
  computeUserQualifiersFromPredictions,
  enrichQualifiersForApi,
  syncUserQualifierPredictions
} from "../qualifiers/fromPredictions.js";
import { fetchUserScores } from "../leaderboard/userScores.js";
import { isGroupStageComplete } from "../scoring/qualifiers.js";
import { getMatchScoringBreakdown } from "../matches/matchScoringBreakdown.js";

const calendarQuerySchema = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  stage: z.enum(["GROUP", "KNOCKOUT"]).optional()
});

export const predictionsRouter = Router();
predictionsRouter.use(requireAuth);

predictionsRouter.get("/me/calendar", async (req, res, next) => {
  try {
    const { date, stage } = calendarQuerySchema.parse(req.query);
    const userId = req.user!.id;
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId) {
      res.json({ date, matches: [] });
      return;
    }

    const conditions = [
      activeTournamentCondition("m", 1),
      `${matchCalendarDateSql("m")} = $2::date`
    ];
    const params: unknown[] = [tournamentId, date, userId];
    if (stage) {
      params.push(stage);
      conditions.push(`m.stage = $${params.length}`);
    }

    const result = await pool.query(
      `SELECT ${matchSelectFields},
        p.predicted_home_score,
        p.predicted_away_score,
        p.predicted_advancing_team_id,
        ${predictionBracketSelectFields},
        CASE WHEN ps.points IS NULL AND pz.points IS NULL THEN NULL
             ELSE COALESCE(ps.points, 0) + COALESCE(pz.points, 0) END AS earned_points,
        CASE WHEN ps.breakdown IS NULL AND pz.breakdown IS NULL THEN NULL
             ELSE COALESCE(ps.breakdown, '{}'::jsonb) || COALESCE(pz.breakdown, '{}'::jsonb) END AS earned_breakdown
      ${matchFromClause}
      LEFT JOIN predictions p ON p.match_id = m.id AND p.user_id = $3
      ${predictionBracketJoinClause}
      LEFT JOIN prediction_scores ps ON ps.source_type = 'MATCH' AND ps.source_id = m.id AND ps.user_id = $3
      LEFT JOIN prediction_scores pz ON pz.source_type = 'BRACKET_PRIZE' AND pz.source_id = m.id AND pz.user_id = $3
      WHERE ${conditions.join(" AND ")}
      ORDER BY m.starts_at ASC`,
      params
    );

    await applyResolvedTeamsToMatchRows(userId, result.rows);
    await enrichKnockoutAdvancingOnRows(userId, result.rows);

    const hasKnockout = result.rows.some((row) => row.stage === "KNOCKOUT");
    const knockoutConfig = hasKnockout ? await loadKnockoutPredictionConfig() : null;
    const groupStageComplete = hasKnockout ? await isGroupStageComplete() : false;

    const matches = await Promise.all(
      result.rows.map(async (row) => {
        const lockAt = await resolvePredictionLockAt(row);
        const availability = await buildPredictionAvailability(
          row,
          lockAt,
          new Date(),
          knockoutConfig,
          groupStageComplete
        );
        return mapCalendarMatchRow(row, availability, lockAt);
      })
    );

    res.json({ date, matches });
  } catch (error) {
    next(error);
  }
});

type PredictionInput = z.infer<typeof predictionSchema>;

type SaveResult =
  | { ok: true; row: Record<string, unknown>; stage: string | null }
  | { ok: false; status: number; message: string; lockAt?: string };

/**
 * Guarda (upsert) un pronóstico de un usuario validando ventana/cierre. No ejecuta la
 * sincronización de clasificados/bonos; el caller decide hacerla una sola vez (clave para batch).
 * `precomputed` permite reusar config KO y estado de grupos sin recalcular por partido.
 */
async function saveOnePrediction(
  userId: number,
  input: PredictionInput,
  precomputed?: { knockoutConfig?: Awaited<ReturnType<typeof loadKnockoutPredictionConfig>>; groupStageComplete?: boolean }
): Promise<SaveResult> {
  const matchResult = await pool.query("SELECT * FROM matches WHERE id = $1", [input.matchId]);
  const match = matchResult.rows[0];
  if (!match) {
    return { ok: false, status: 404, message: "Partido no encontrado" };
  }

  const isKnockout = match.stage === "KNOCKOUT";
  const lockAt = await resolvePredictionLockAt(match);
  const knockoutConfig = isKnockout
    ? (precomputed?.knockoutConfig ?? (await loadKnockoutPredictionConfig()))
    : null;
  const groupStageComplete = isKnockout
    ? (precomputed?.groupStageComplete ?? (await isGroupStageComplete()))
    : false;

  const closedReason = knockoutPredictionClosedReason(
    match,
    lockAt,
    new Date(),
    knockoutConfig,
    groupStageComplete
  );
  if (closedReason) {
    return { ok: false, status: 400, message: closedReason, lockAt: lockAt.toISOString() };
  }

  const advancingTeamId = await resolveKnockoutAdvancingForSave(
    match,
    userId,
    input.predictedHomeScore,
    input.predictedAwayScore,
    input.predictedAdvancingTeamId ?? null
  );

  if (requiresKnockoutAdvancingTeam(match) && advancingTeamId == null) {
    return {
      ok: false,
      status: 400,
      message:
        input.predictedHomeScore === input.predictedAwayScore
          ? "En empate debes indicar quién gana en penales y pasa a la siguiente ronda"
          : "No se pudo determinar el equipo que avanza"
    };
  }

  let bracketHomeId: number | null = null;
  let bracketAwayId: number | null = null;
  if (isKnockout) {
    const slot = await resolveUserSlotTeamsForMatch(userId, match);
    if (slot) {
      bracketHomeId = slot.homeTeamId;
      bracketAwayId = slot.awayTeamId;
    }
  }

  const result = await pool.query(
    `INSERT INTO predictions (
      user_id, match_id, predicted_home_score, predicted_away_score,
      predicted_advancing_team_id, bracket_home_team_id, bracket_away_team_id
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    ON CONFLICT (user_id, match_id)
    DO UPDATE SET
      predicted_home_score = EXCLUDED.predicted_home_score,
      predicted_away_score = EXCLUDED.predicted_away_score,
      predicted_advancing_team_id = EXCLUDED.predicted_advancing_team_id,
      bracket_home_team_id = EXCLUDED.bracket_home_team_id,
      bracket_away_team_id = EXCLUDED.bracket_away_team_id,
      updated_at = NOW()
    RETURNING *`,
    [
      userId,
      input.matchId,
      input.predictedHomeScore,
      input.predictedAwayScore,
      advancingTeamId,
      bracketHomeId,
      bracketAwayId
    ]
  );

  return { ok: true, row: result.rows[0], stage: match.stage ?? null };
}

predictionsRouter.post("/", async (req, res, next) => {
  try {
    const input = predictionSchema.parse(req.body);
    const result = await saveOnePrediction(req.user!.id, input);
    if (!result.ok) {
      res.status(result.status).json({ message: result.message, lockAt: result.lockAt });
      return;
    }

    if (result.stage === "GROUP") {
      await syncUserQualifierPredictions(req.user!.id);
    } else if (result.stage === "KNOCKOUT") {
      await syncUserBonusPicksFromBracket(req.user!.id);
    }

    res.status(201).json(result.row);
  } catch (error) {
    next(error);
  }
});

const batchPredictionSchema = z.object({
  predictions: z.array(predictionSchema).min(1).max(64)
});

predictionsRouter.post("/batch", async (req, res, next) => {
  try {
    const { predictions } = batchPredictionSchema.parse(req.body);
    const userId = req.user!.id;
    const knockoutConfig = await loadKnockoutPredictionConfig();
    const groupStageComplete = await isGroupStageComplete();

    let saved = 0;
    let savedGroup = false;
    let savedKnockout = false;
    const errors: Array<{ matchId: number; message: string }> = [];

    for (const input of predictions) {
      const result = await saveOnePrediction(userId, input, { knockoutConfig, groupStageComplete });
      if (result.ok) {
        saved += 1;
        if (result.stage === "GROUP") savedGroup = true;
        else if (result.stage === "KNOCKOUT") savedKnockout = true;
      } else {
        errors.push({ matchId: input.matchId, message: result.message });
      }
    }

    // Sincronización una sola vez al final, no por partido.
    if (savedGroup) await syncUserQualifierPredictions(userId);
    if (savedKnockout) await syncUserBonusPicksFromBracket(userId);

    res.status(errors.length > 0 && saved === 0 ? 400 : 200).json({ saved, errors });
  } catch (error) {
    next(error);
  }
});

predictionsRouter.get("/me/scores", async (req, res, next) => {
  try {
    res.json(await fetchUserScores(req.user!.id));
  } catch (error) {
    next(error);
  }
});

predictionsRouter.get("/me/bracket", async (req, res, next) => {
  try {
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId) {
      res.json({ rounds: [] });
      return;
    }
    const userId = req.user!.id;
    const result = await pool.query(
      `SELECT ${matchSelectFields},
        p.predicted_home_score,
        p.predicted_away_score,
        p.predicted_advancing_team_id,
        ${predictionBracketSelectFields},
        CASE WHEN ps.points IS NULL AND pz.points IS NULL THEN NULL
             ELSE COALESCE(ps.points, 0) + COALESCE(pz.points, 0) END AS earned_points,
        CASE WHEN ps.breakdown IS NULL AND pz.breakdown IS NULL THEN NULL
             ELSE COALESCE(ps.breakdown, '{}'::jsonb) || COALESCE(pz.breakdown, '{}'::jsonb) END AS earned_breakdown
      ${matchFromClause}
      LEFT JOIN predictions p ON p.match_id = m.id AND p.user_id = $2
      ${predictionBracketJoinClause}
      LEFT JOIN prediction_scores ps ON ps.source_type = 'MATCH' AND ps.source_id = m.id AND ps.user_id = $2
      LEFT JOIN prediction_scores pz ON pz.source_type = 'BRACKET_PRIZE' AND pz.source_id = m.id AND pz.user_id = $2
      WHERE ${activeTournamentCondition("m", 1)} AND m.stage = 'KNOCKOUT'
      ORDER BY
        CASE m.round_key
          WHEN 'R16' THEN 1
          WHEN 'R8' THEN 2
          WHEN 'R4' THEN 3
          WHEN 'SF' THEN 4
          WHEN 'TP3' THEN 5
          WHEN 'F' THEN 6
          ELSE 7
        END,
        m.starts_at ASC`,
      [tournamentId, userId]
    );

    await syncAllOfficialKnockoutAdvancement(tournamentId);
    await applyResolvedTeamsToMatchRows(userId, result.rows);
    await enrichKnockoutAdvancingOnRows(userId, result.rows);

    const knockoutConfig = await loadKnockoutPredictionConfig();
    const groupStageComplete = await isGroupStageComplete();
    const now = new Date();

    const roundOrder = ["R16", "R8", "R4", "SF", "TP3", "F"] as const;
    const roundLabels: Record<string, string> = {
      R16: "Dieciseisavos (Fase 1)",
      R8: "Octavos de final (Fase 2)",
      R4: "Cuartos de final",
      SF: "Semifinales",
      TP3: "Tercer puesto",
      F: "Final"
    };

    const byRound = new Map<string, unknown[]>();
    for (const row of result.rows) {
      const key = (row.round_key as string) ?? "R16";
      if (!byRound.has(key)) byRound.set(key, []);
      const lockAt = await resolvePredictionLockAt(row);
      const availability = await buildPredictionAvailability(
        row,
        lockAt,
        now,
        knockoutConfig,
        groupStageComplete
      );
      byRound.get(key)!.push(mapCalendarMatchRow(row, availability, lockAt));
    }

    res.json({
      rounds: roundOrder
        .filter((k) => byRound.has(k))
        .map((k) => ({
          roundKey: k,
          title: roundLabels[k] ?? k,
          predictionWindow: buildKnockoutPredictionWindowApi(k, now, knockoutConfig, groupStageComplete),
          matches: byRound.get(k) ?? []
        })),
      knockoutGlobalWindow: {
        openDate: knockoutConfig.openDate,
        closeDate: knockoutConfig.closeDate
      },
      groupStageComplete
    });
  } catch (error) {
    next(error);
  }
});

predictionsRouter.get("/me/r16-bracket", async (req, res, next) => {
  try {
    const { getPredictedR16Bracket } = await import("../bracket/r16Service.js");
    const userId = req.user!.id;
    const predicted = await getPredictedR16Bracket(userId);
    const { getOfficialR16Bracket } = await import("../bracket/r16Service.js");
    const official = await getOfficialR16Bracket();
    res.json({ predicted, official });
  } catch (error) {
    next(error);
  }
});

predictionsRouter.get("/me/qualifiers", async (req, res, next) => {
  try {
    const userId = req.user!.id;
    await syncUserQualifierPredictions(userId);
    const stats = await computeUserQualifiersFromPredictions(userId);
    res.json(await enrichQualifiersForApi(userId, stats));
  } catch (error) {
    next(error);
  }
});

predictionsRouter.post("/me/qualifiers/recompute", async (req, res, next) => {
  try {
    const userId = req.user!.id;
    await syncUserQualifierPredictions(userId);
    const stats = await computeUserQualifiersFromPredictions(userId);
    res.json(await enrichQualifiersForApi(userId, stats));
  } catch (error) {
    next(error);
  }
});

/** Ventana para llenar goleador/asistidor; sin fechas configuradas queda siempre abierta. */
async function getExtrasWindow(): Promise<{
  openDate: string | null;
  closeDate: string | null;
  open: boolean;
}> {
  const ymd = /^\d{4}-\d{2}-\d{2}$/;
  const rawOpen = (await getSetting("extras_open_date", "")).trim();
  const rawClose = (await getSetting("extras_close_date", "")).trim();
  const openDate = ymd.test(rawOpen) ? rawOpen : null;
  const closeDate = ymd.test(rawClose) ? rawClose : null;
  const today = formatVenueCalendarDate();
  const open = (!openDate || today >= openDate) && (!closeDate || today <= closeDate);
  return { openDate, closeDate, open };
}

predictionsRouter.get("/me/bonuses", async (req, res, next) => {
  try {
    const userId = req.user!.id;
    const derived = await syncUserBonusPicksFromBracket(userId);
    const teams = await pool.query(
      `SELECT id, name, logo_url FROM teams
      WHERE external_id LIKE 'wc2026-%' AND external_id != 'wc2026-tbd'
      ORDER BY name`
    );
    const row = await pool.query(
      "SELECT top_scorer, top_assister FROM bonus_predictions WHERE user_id = $1",
      [userId]
    );
    const score = await pool.query(
      `SELECT points, breakdown FROM prediction_scores
      WHERE user_id = $1 AND source_type = 'BONUSES' AND source_id = 0`,
      [userId]
    );
    const extras = row.rows[0];
    res.json({
      teams: teams.rows.map((t) => ({
        id: Number(t.id),
        name: t.name,
        logoUrl: t.logo_url
      })),
      picks: {
        championTeamId: derived.championTeamId,
        runnerUpTeamId: derived.runnerUpTeamId,
        thirdPlaceTeamId: derived.thirdPlaceTeamId,
        semifinalistTeamIds: derived.semifinalistTeamIds,
        finalistTeamIds: derived.finalistTeamIds,
        topScorer: extras?.top_scorer ?? null,
        topAssister: extras?.top_assister ?? null
      },
      earnedPoints: score.rows[0]?.points ?? null,
      earnedBreakdown: score.rows[0]?.breakdown ?? null,
      derivedFromBracket: true,
      extrasWindow: await getExtrasWindow()
    });
  } catch (error) {
    next(error);
  }
});

const bonusExtrasSchema = z.object({
  topScorer: z.string().max(120).nullable().optional(),
  topAssister: z.string().max(120).nullable().optional()
});

predictionsRouter.put("/me/bonuses", async (req, res, next) => {
  try {
    const input = bonusExtrasSchema.parse(req.body);
    const window = await getExtrasWindow();
    if (!window.open) {
      const today = formatVenueCalendarDate();
      res.status(400).json({
        message:
          window.openDate && today < window.openDate
            ? `El goleador y asistidor se podrán llenar desde el ${window.openDate}`
            : `El plazo para llenar goleador y asistidor cerró el ${window.closeDate}`
      });
      return;
    }
    const userId = req.user!.id;
    const derived = await syncUserBonusPicksFromBracket(userId);
    await pool.query(
      `INSERT INTO bonus_predictions (
        user_id, champion_team_id, runner_up_team_id, third_place_team_id,
        semifinalist_team_ids, finalist_team_ids, top_scorer, top_assister
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
      ON CONFLICT (user_id) DO UPDATE SET
        champion_team_id = EXCLUDED.champion_team_id,
        runner_up_team_id = EXCLUDED.runner_up_team_id,
        third_place_team_id = EXCLUDED.third_place_team_id,
        semifinalist_team_ids = EXCLUDED.semifinalist_team_ids,
        finalist_team_ids = EXCLUDED.finalist_team_ids,
        top_scorer = EXCLUDED.top_scorer,
        top_assister = EXCLUDED.top_assister`,
      [
        userId,
        derived.championTeamId,
        derived.runnerUpTeamId,
        derived.thirdPlaceTeamId,
        derived.semifinalistTeamIds,
        derived.finalistTeamIds,
        input.topScorer ?? null,
        input.topAssister ?? null
      ]
    );
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

predictionsRouter.get("/matches/:id/scoring", async (req, res, next) => {
  try {
    const matchId = z.coerce.number().int().positive().parse(req.params.id);
    const data = await getMatchScoringBreakdown(matchId);
    if (!data) {
      res.status(404).json({ message: "Partido no encontrado" });
      return;
    }
    if (data.match.status !== "FINISHED") {
      res.status(400).json({ message: "Los puntos del grupo se publican cuando el partido está finalizado." });
      return;
    }
    res.json(data);
  } catch (error) {
    next(error);
  }
});

predictionsRouter.get("/me", async (req, res, next) => {
  try {
    const result = await pool.query(
      `SELECT p.*, m.starts_at, m.prediction_lock_at, m.matchday, m.round_label,
        ht.name AS home_team_name, at.name AS away_team_name
      FROM predictions p
      JOIN matches m ON m.id = p.match_id
      JOIN teams ht ON ht.id = m.home_team_id
      JOIN teams at ON at.id = m.away_team_id
      WHERE p.user_id = $1
      ORDER BY m.starts_at`,
      [req.user!.id]
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
});
