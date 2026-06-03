import { Router } from "express";
import { z } from "zod";
import { pool } from "../../db/pool.js";
import { requireAuth } from "../../middlewares/auth.js";
import { matchCalendarDateSql } from "../matches/calendarDate.js";
import { activeTournamentCondition, matchFromClause, matchSelectFields } from "../matches/query.js";
import {
  buildPredictionAvailability,
  getActiveTournamentId,
  loadKnockoutPredictionConfig,
  knockoutPredictionClosedReason,
  resolvePredictionLockAt
} from "../settings/service.js";
import { buildKnockoutPredictionWindowApi } from "../bracket/knockoutPredictionWindow.js";
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
import { syncUserBonusPicksFromBracket } from "../bracket/deriveBonusFromBracket.js";
import { requiresKnockoutAdvancingTeam } from "../scoring/rulesConfig.js";
import {
  computeUserQualifiersFromPredictions,
  enrichQualifiersForApi,
  syncUserQualifierPredictions
} from "../qualifiers/fromPredictions.js";
import { fetchUserScores } from "../leaderboard/userScores.js";

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
        ps.points AS earned_points,
        ps.breakdown AS earned_breakdown
      ${matchFromClause}
      LEFT JOIN predictions p ON p.match_id = m.id AND p.user_id = $3
      LEFT JOIN prediction_scores ps ON ps.source_type = 'MATCH' AND ps.source_id = m.id AND ps.user_id = $3
      WHERE ${conditions.join(" AND ")}
      ORDER BY m.starts_at ASC`,
      params
    );

    await applyResolvedTeamsToMatchRows(userId, result.rows);
    await enrichKnockoutAdvancingOnRows(userId, result.rows);

    const knockoutConfig = result.rows.some((row) => row.stage === "KNOCKOUT")
      ? await loadKnockoutPredictionConfig()
      : null;

    const matches = await Promise.all(
      result.rows.map(async (row) => {
        const lockAt = await resolvePredictionLockAt(row);
        const availability = await buildPredictionAvailability(row, lockAt, new Date(), knockoutConfig);
        return {
          id: row.id,
          stage: row.stage,
          roundKey: row.round_key,
          status: row.status,
          startsAt: row.starts_at,
          kickoffTimeLocal: row.kickoff_time_local,
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
          winnerTeamId: row.winner_team_id ? Number(row.winner_team_id) : null,
          ...availability,
          predictionLockAt: lockAt.toISOString(),
          prediction:
            row.predicted_home_score != null
              ? {
                  predictedHomeScore: row.predicted_home_score,
                  predictedAwayScore: row.predicted_away_score,
                  predictedAdvancingTeamId: row.predicted_advancing_team_id
                    ? Number(row.predicted_advancing_team_id)
                    : null
                }
              : null,
          advancingTeamId: row.advancingTeamId ? Number(row.advancingTeamId) : null,
          advancingTeamName: (row.advancingTeamName as string) ?? null,
          advancingTeamLogoUrl: (row.advancingTeamLogoUrl as string | null) ?? null,
          advancingViaPenalties: Boolean(row.advancingViaPenalties),
          nextRoundLabel: (row.nextRoundLabel as string) ?? null,
          earnedPoints: row.earned_points ?? null,
          earnedBreakdown: row.earned_breakdown ?? null
        };
      })
    );

    res.json({ date, matches });
  } catch (error) {
    next(error);
  }
});

predictionsRouter.post("/", async (req, res, next) => {
  try {
    const input = predictionSchema.parse(req.body);
    const matchResult = await pool.query("SELECT * FROM matches WHERE id = $1", [input.matchId]);
    const match = matchResult.rows[0];
    if (!match) {
      res.status(404).json({ message: "Partido no encontrado" });
      return;
    }

    const lockAt = await resolvePredictionLockAt(match);
    const knockoutConfig =
      match.stage === "KNOCKOUT" ? await loadKnockoutPredictionConfig() : null;
    const closedReason = knockoutPredictionClosedReason(match, lockAt, new Date(), knockoutConfig);
    if (closedReason) {
      res.status(400).json({ message: closedReason, lockAt: lockAt.toISOString() });
      return;
    }

    const advancingTeamId = await resolveKnockoutAdvancingForSave(
      match,
      req.user!.id,
      input.predictedHomeScore,
      input.predictedAwayScore,
      input.predictedAdvancingTeamId ?? null
    );

    if (requiresKnockoutAdvancingTeam(match) && advancingTeamId == null) {
      res.status(400).json({
        message:
          input.predictedHomeScore === input.predictedAwayScore
            ? "En empate debes indicar quién gana en penales y pasa a la siguiente ronda"
            : "No se pudo determinar el equipo que avanza"
      });
      return;
    }

    const result = await pool.query(
      `INSERT INTO predictions (user_id, match_id, predicted_home_score, predicted_away_score, predicted_advancing_team_id)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (user_id, match_id)
      DO UPDATE SET
        predicted_home_score = EXCLUDED.predicted_home_score,
        predicted_away_score = EXCLUDED.predicted_away_score,
        predicted_advancing_team_id = EXCLUDED.predicted_advancing_team_id,
        updated_at = NOW()
      RETURNING *`,
      [
        req.user!.id,
        input.matchId,
        input.predictedHomeScore,
        input.predictedAwayScore,
        advancingTeamId
      ]
    );

    if (match.stage === "GROUP") {
      await syncUserQualifierPredictions(req.user!.id);
    } else if (match.stage === "KNOCKOUT") {
      await syncUserBonusPicksFromBracket(req.user!.id);
    }

    res.status(201).json(result.rows[0]);
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
        ps.points AS earned_points,
        ps.breakdown AS earned_breakdown
      ${matchFromClause}
      LEFT JOIN predictions p ON p.match_id = m.id AND p.user_id = $2
      LEFT JOIN prediction_scores ps ON ps.source_type = 'MATCH' AND ps.source_id = m.id AND ps.user_id = $2
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
      const availability = await buildPredictionAvailability(row, lockAt, now, knockoutConfig);
      byRound.get(key)!.push({
        id: row.id,
        stage: row.stage,
        roundKey: key,
        status: row.status,
        startsAt: row.starts_at,
        kickoffTimeLocal: row.kickoff_time_local,
        roundLabel: row.round_label,
        homeTeamId: Number(row.home_team_id),
        homeTeamName: row.home_team_name,
        homeTeamLogoUrl: row.home_team_logo_url,
        awayTeamId: Number(row.away_team_id),
        awayTeamName: row.away_team_name,
        awayTeamLogoUrl: row.away_team_logo_url,
        homeScore: row.home_score,
        awayScore: row.away_score,
        winnerTeamId: row.winner_team_id ? Number(row.winner_team_id) : null,
        ...availability,
        predictionLockAt: lockAt.toISOString(),
        prediction:
          row.predicted_home_score != null
            ? {
                predictedHomeScore: row.predicted_home_score,
                predictedAwayScore: row.predicted_away_score,
                predictedAdvancingTeamId: row.predicted_advancing_team_id
                  ? Number(row.predicted_advancing_team_id)
                  : null
              }
            : null,
        advancingTeamId: row.advancingTeamId ? Number(row.advancingTeamId) : null,
        advancingTeamName: (row.advancingTeamName as string) ?? null,
        advancingTeamLogoUrl: (row.advancingTeamLogoUrl as string | null) ?? null,
        advancingViaPenalties: Boolean(row.advancingViaPenalties),
        nextRoundLabel: (row.nextRoundLabel as string) ?? null,
        earnedPoints: row.earned_points ?? null,
        earnedBreakdown: row.earned_breakdown ?? null
      });
    }

    res.json({
      rounds: roundOrder
        .filter((k) => byRound.has(k))
        .map((k) => ({
          roundKey: k,
          title: roundLabels[k] ?? k,
          predictionWindow: buildKnockoutPredictionWindowApi(k, now, knockoutConfig),
          matches: byRound.get(k) ?? []
        })),
      knockoutGlobalWindow: {
        openDate: knockoutConfig.openDate,
        closeDate: knockoutConfig.closeDate
      }
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
      derivedFromBracket: true
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
