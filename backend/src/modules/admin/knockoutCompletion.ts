import { Router } from "express";
import { z } from "zod";
import { pool } from "../../db/pool.js";
import { requireAdmin, requireAuth } from "../../middlewares/auth.js";
import { getActiveTournamentId } from "../settings/service.js";
import { repairOfficialKnockoutBracket } from "../bracket/knockoutRepair.js";
import { buildUserKnockoutBracketView } from "../bracket/userKnockoutBracketView.js";
import { resyncUserBracketSnapshots } from "../bracket/userBracketSnapshotResync.js";
import { resolveKnockoutAdvancingForSave } from "../bracket/knockoutAdvancingSave.js";
import { resolveUserSlotTeamsForMatch } from "../bracket/resolveUserSlotTeams.js";
import { syncUserBonusPicksFromBracket } from "../bracket/deriveBonusFromBracket.js";
import { optionalTeamId } from "../../utils/zodHelpers.js";

const ROUND_ORDER = ["R16", "R8", "R4", "SF", "TP3", "F"] as const;

const ROUND_LABELS: Record<string, string> = {
  R16: "Dieciseisavos",
  R8: "Octavos",
  R4: "Cuartos",
  SF: "Semis",
  TP3: "3er puesto",
  F: "Final"
};

export const adminKnockoutCompletionRouter = Router();
adminKnockoutCompletionRouter.use(requireAuth, requireAdmin);

/**
 * Detalle por ronda y total de cuántos cruces de eliminatoria llenó cada usuario activo,
 * incluyendo a quienes no llenaron nada (para detectar faltantes).
 */
adminKnockoutCompletionRouter.get("/knockout-completion", async (_req, res, next) => {
  try {
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId) {
      res.json({ roundOrder: [], roundLabels: ROUND_LABELS, roundTotals: {}, totalMatches: 0, users: [] });
      return;
    }

    const totalsRes = await pool.query(
      `SELECT round_key, COUNT(*)::int AS total
      FROM matches
      WHERE tournament_id = $1 AND stage = 'KNOCKOUT'
      GROUP BY round_key`,
      [tournamentId]
    );
    const roundTotals: Record<string, number> = {};
    let totalMatches = 0;
    for (const row of totalsRes.rows) {
      roundTotals[row.round_key] = row.total;
      totalMatches += row.total;
    }
    const roundOrder = ROUND_ORDER.filter((k) => roundTotals[k] != null);

    const usersRes = await pool.query(
      `SELECT id, email, display_name
      FROM users
      WHERE is_active = true
      ORDER BY display_name NULLS LAST, email`
    );

    const filledRes = await pool.query(
      `SELECT p.user_id, m.round_key, COUNT(*)::int AS filled
      FROM predictions p
      JOIN matches m ON m.id = p.match_id
      WHERE m.tournament_id = $1 AND m.stage = 'KNOCKOUT'
      GROUP BY p.user_id, m.round_key`,
      [tournamentId]
    );
    const byUser = new Map<number, Record<string, number>>();
    for (const row of filledRes.rows) {
      const current = byUser.get(row.user_id) ?? {};
      current[row.round_key] = row.filled;
      byUser.set(row.user_id, current);
    }

    const users = usersRes.rows.map((u) => {
      const perUserFilled = byUser.get(u.id) ?? {};
      const perRound: Record<string, { filled: number; total: number }> = {};
      let totalFilled = 0;
      for (const k of roundOrder) {
        const filled = perUserFilled[k] ?? 0;
        perRound[k] = { filled, total: roundTotals[k] };
        totalFilled += filled;
      }
      return {
        userId: u.id,
        email: u.email,
        displayName: u.display_name,
        perRound,
        totalFilled,
        totalMatches,
        complete: totalMatches > 0 && totalFilled >= totalMatches
      };
    });

    res.json({ roundOrder, roundLabels: ROUND_LABELS, roundTotals, totalMatches, users });
  } catch (error) {
    next(error);
  }
});

/** Diagnóstico (sin escribir): qué cruces oficiales quedaron inconsistentes y cómo se corregirían. */
adminKnockoutCompletionRouter.get("/knockout-repair", async (_req, res, next) => {
  try {
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId) {
      res.json({ applied: false, totalChanges: 0, changedSlots: [], changedWinners: [], needsReview: [], rescoredMatches: [] });
      return;
    }
    res.json(await repairOfficialKnockoutBracket(tournamentId, { apply: false }));
  } catch (error) {
    next(error);
  }
});

/** Aplica la corrección: recoloca equipos en el cuadro oficial y vuelve a puntuar lo afectado. */
adminKnockoutCompletionRouter.post("/knockout-repair", async (_req, res, next) => {
  try {
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId) {
      res.status(400).json({ message: "No hay torneo activo" });
      return;
    }
    res.json(await repairOfficialKnockoutBracket(tournamentId, { apply: true }));
  } catch (error) {
    next(error);
  }
});

/** Diagnóstico (sin escribir): qué snapshots de usuarios quedaron viejos respecto a su cuadro en vivo. */
adminKnockoutCompletionRouter.get("/knockout-resync-snapshots", async (_req, res, next) => {
  try {
    res.json(await resyncUserBracketSnapshots({ apply: false }));
  } catch (error) {
    next(error);
  }
});

/** Resincroniza los cruces guardados de cada usuario con su cuadro en vivo y vuelve a puntuar. */
adminKnockoutCompletionRouter.post("/knockout-resync-snapshots", async (_req, res, next) => {
  try {
    res.json(await resyncUserBracketSnapshots({ apply: true }));
  } catch (error) {
    next(error);
  }
});

const setPredictionSchema = z.object({
  matchId: z.coerce.number().int().positive(),
  predictedHomeScore: z.coerce.number().int().min(0).max(99),
  predictedAwayScore: z.coerce.number().int().min(0).max(99),
  predictedAdvancingTeamId: optionalTeamId
});

/**
 * El admin edita el marcador predicho de un usuario en un partido de eliminatoria y recalcula:
 * resuelve quién avanza, guarda el cruce, resincroniza las rondas siguientes de ese usuario y, si el
 * partido ya está finalizado, vuelve a puntuar. Devuelve el cuadro actualizado para refrescar el árbol.
 */
adminKnockoutCompletionRouter.put("/knockout-bracket/:userId/prediction", async (req, res, next) => {
  try {
    const userId = z.coerce.number().int().positive().parse(req.params.userId);
    const input = setPredictionSchema.parse(req.body);

    const user = await pool.query("SELECT id FROM users WHERE id = $1", [userId]);
    if (!user.rows[0]) {
      res.status(404).json({ message: "Usuario no encontrado" });
      return;
    }

    const matchRes = await pool.query("SELECT * FROM matches WHERE id = $1", [input.matchId]);
    const match = matchRes.rows[0];
    if (!match) {
      res.status(404).json({ message: "Partido no encontrado" });
      return;
    }
    if (match.stage !== "KNOCKOUT") {
      res.status(400).json({ message: "Solo se editan aquí partidos de eliminatoria" });
      return;
    }

    const advancingTeamId = await resolveKnockoutAdvancingForSave(
      match,
      userId,
      input.predictedHomeScore,
      input.predictedAwayScore,
      input.predictedAdvancingTeamId ?? null
    );

    // En el cuadro toda llave necesita un ganador que avance: un empate (en cualquier ronda,
    // incluidos dieciseisavos) exige indicar quién pasa en penales.
    if (input.predictedHomeScore === input.predictedAwayScore && advancingTeamId == null) {
      res.status(400).json({
        message: "En empate debes indicar quién gana en penales y pasa a la siguiente ronda"
      });
      return;
    }
    if (advancingTeamId == null) {
      res.status(400).json({ message: "No se pudo determinar el equipo que avanza" });
      return;
    }

    const slot = await resolveUserSlotTeamsForMatch(userId, match);
    const bracketHomeId = slot?.homeTeamId ?? null;
    const bracketAwayId = slot?.awayTeamId ?? null;

    if (
      advancingTeamId != null &&
      bracketHomeId != null &&
      bracketAwayId != null &&
      advancingTeamId !== bracketHomeId &&
      advancingTeamId !== bracketAwayId
    ) {
      res.status(400).json({ message: "El equipo que avanza debe ser uno de los del cruce" });
      return;
    }

    await pool.query(
      `INSERT INTO predictions (
        user_id, match_id, predicted_home_score, predicted_away_score,
        predicted_advancing_team_id, bracket_home_team_id, bracket_away_team_id
      ) VALUES ($1,$2,$3,$4,$5,$6,$7)
      ON CONFLICT (user_id, match_id) DO UPDATE SET
        predicted_home_score = EXCLUDED.predicted_home_score,
        predicted_away_score = EXCLUDED.predicted_away_score,
        predicted_advancing_team_id = EXCLUDED.predicted_advancing_team_id,
        bracket_home_team_id = EXCLUDED.bracket_home_team_id,
        bracket_away_team_id = EXCLUDED.bracket_away_team_id,
        updated_at = NOW()`,
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

    // Cambiar una ronda mueve a quién avanza: resincroniza los cruces guardados de las rondas
    // siguientes de este usuario y vuelve a puntuar las que ya estén finalizadas.
    await resyncUserBracketSnapshots({ apply: true, userId });
    try {
      await syncUserBonusPicksFromBracket(userId);
    } catch {
      // Bonos parciales sin datos suficientes aún
    }
    if (match.status === "FINISHED") {
      const { calculateMatchScores } = await import("../scoring/service.js");
      await calculateMatchScores(input.matchId);
    }

    const matches = await buildUserKnockoutBracketView(userId);
    res.json({ matches, message: "Predicción actualizada y cuadro recalculado" });
  } catch (error) {
    next(error);
  }
});

/** Cuadro eliminatorio simulado de un usuario (lo que predijo) para verlo como ramificación. */
adminKnockoutCompletionRouter.get("/knockout-bracket/:userId", async (req, res, next) => {
  try {
    const userId = z.coerce.number().int().positive().parse(req.params.userId);
    const user = await pool.query("SELECT id, email, display_name FROM users WHERE id = $1", [userId]);
    if (!user.rows[0]) {
      res.status(404).json({ message: "Usuario no encontrado" });
      return;
    }
    const matches = await buildUserKnockoutBracketView(userId);
    res.json({
      user: {
        id: user.rows[0].id,
        email: user.rows[0].email,
        displayName: user.rows[0].display_name
      },
      matches
    });
  } catch (error) {
    next(error);
  }
});
