import { Router } from "express";
import { pool } from "../../db/pool.js";
import { requireAdmin, requireAuth } from "../../middlewares/auth.js";
import { getActiveTournamentId } from "../settings/service.js";

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
