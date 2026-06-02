import { Router } from "express";
import bcrypt from "bcrypt";
import { z } from "zod";
import { pool } from "../../db/pool.js";
import { requireAdmin, requireAuth } from "../../middlewares/auth.js";
import { finalizeMatch } from "../scoring/finalize.js";
import { knockoutPredictionClosedReason, loadKnockoutPredictionConfig, resolvePredictionLockAt } from "../settings/service.js";

import { loginIdentifierSchema, normalizeLoginIdentifier } from "../../utils/loginIdentifier.js";

const createUserSchema = z.object({
  login: loginIdentifierSchema,
  password: z.string().min(6),
  displayName: z.string().min(1).max(120).optional(),
  role: z.enum(["USER", "ADMIN"]).default("USER"),
  amountPaid: z.number().min(0).default(0),
  paymentNotes: z.string().max(500).optional()
});

const updateUserSchema = z.object({
  displayName: z.string().min(1).max(120).nullable().optional(),
  amountPaid: z.number().min(0).optional(),
  paymentNotes: z.string().max(500).nullable().optional(),
  password: z.string().min(6).optional()
});

const adminPredictionSchema = z.object({
  matchId: z.coerce.number().int().positive(),
  predictedHomeScore: z.coerce.number().int().min(0),
  predictedAwayScore: z.coerce.number().int().min(0)
});

export const adminUsersRouter = Router();
adminUsersRouter.use(requireAuth, requireAdmin);

adminUsersRouter.get("/", async (_req, res, next) => {
  try {
    const result = await pool.query(
      `SELECT
        u.id,
        u.email,
        u.display_name,
        u.role,
        u.amount_paid,
        u.payment_notes,
        u.created_at,
        COALESCE(SUM(ps.points), 0)::int AS total_points,
        COUNT(DISTINCT p.id)::int AS predictions_count
      FROM users u
      LEFT JOIN prediction_scores ps ON ps.user_id = u.id
      LEFT JOIN predictions p ON p.user_id = u.id
      GROUP BY u.id
      ORDER BY u.email`
    );
    res.json(
      result.rows.map((row) => ({
        id: row.id,
        email: row.email,
        displayName: row.display_name,
        role: row.role,
        amountPaid: Number(row.amount_paid),
        paymentNotes: row.payment_notes,
        createdAt: row.created_at,
        totalPoints: row.total_points,
        predictionsCount: row.predictions_count
      }))
    );
  } catch (error) {
    next(error);
  }
});

adminUsersRouter.post("/", async (req, res, next) => {
  try {
    const input = createUserSchema.parse(req.body);
    const login = normalizeLoginIdentifier(input.login);
    const passwordHash = await bcrypt.hash(input.password, 10);
    const result = await pool.query(
      `INSERT INTO users (email, password_hash, role, display_name, amount_paid, payment_notes)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id, email, display_name, role, amount_paid, payment_notes, created_at`,
      [
        login,
        passwordHash,
        input.role,
        input.displayName ?? null,
        input.amountPaid,
        input.paymentNotes ?? null
      ]
    );
    const row = result.rows[0];
    res.status(201).json({
      id: row.id,
      email: row.email,
      displayName: row.display_name,
      role: row.role,
      amountPaid: Number(row.amount_paid),
      paymentNotes: row.payment_notes,
      createdAt: row.created_at,
      totalPoints: 0,
      predictionsCount: 0
    });
  } catch (error) {
    next(error);
  }
});

adminUsersRouter.patch("/:id", async (req, res, next) => {
  try {
    const userId = Number(req.params.id);
    const input = updateUserSchema.parse(req.body);

    if (input.password) {
      const passwordHash = await bcrypt.hash(input.password, 10);
      await pool.query("UPDATE users SET password_hash = $1 WHERE id = $2", [passwordHash, userId]);
    }

    const sets: string[] = [];
    const params: unknown[] = [];
    if (input.displayName !== undefined) {
      params.push(input.displayName);
      sets.push(`display_name = $${params.length}`);
    }
    if (input.amountPaid !== undefined) {
      params.push(input.amountPaid);
      sets.push(`amount_paid = $${params.length}`);
    }
    if (input.paymentNotes !== undefined) {
      params.push(input.paymentNotes);
      sets.push(`payment_notes = $${params.length}`);
    }

    if (sets.length === 0 && !input.password) {
      res.status(400).json({ message: "Nada que actualizar" });
      return;
    }

    let result;
    if (sets.length > 0) {
      params.push(userId);
      result = await pool.query(
        `UPDATE users SET ${sets.join(", ")} WHERE id = $${params.length}
        RETURNING id, email, display_name, role, amount_paid, payment_notes, created_at`,
        params
      );
    } else {
      result = await pool.query(
        "SELECT id, email, display_name, role, amount_paid, payment_notes, created_at FROM users WHERE id = $1",
        [userId]
      );
    }

    if (!result.rows[0]) {
      res.status(404).json({ message: "Usuario no encontrado" });
      return;
    }

    const row = result.rows[0];
    const stats = await pool.query(
      `SELECT COALESCE(SUM(points), 0)::int AS total_points,
        (SELECT COUNT(*)::int FROM predictions WHERE user_id = $1) AS predictions_count
      FROM prediction_scores WHERE user_id = $1`,
      [userId]
    );

    res.json({
      id: row.id,
      email: row.email,
      displayName: row.display_name,
      role: row.role,
      amountPaid: Number(row.amount_paid),
      paymentNotes: row.payment_notes,
      createdAt: row.created_at,
      totalPoints: stats.rows[0].total_points,
      predictionsCount: stats.rows[0].predictions_count
    });
  } catch (error) {
    next(error);
  }
});

adminUsersRouter.put("/:userId/predictions", async (req, res, next) => {
  try {
    const userId = Number(req.params.userId);
    const input = adminPredictionSchema.parse(req.body);

    const user = await pool.query("SELECT id FROM users WHERE id = $1", [userId]);
    if (!user.rows[0]) {
      res.status(404).json({ message: "Usuario no encontrado" });
      return;
    }

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
      res.status(400).json({ message: closedReason });
      return;
    }

    const result = await pool.query(
      `INSERT INTO predictions (user_id, match_id, predicted_home_score, predicted_away_score)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (user_id, match_id)
      DO UPDATE SET
        predicted_home_score = EXCLUDED.predicted_home_score,
        predicted_away_score = EXCLUDED.predicted_away_score,
        updated_at = NOW()
      RETURNING *`,
      [userId, input.matchId, input.predictedHomeScore, input.predictedAwayScore]
    );

    res.json({
      prediction: result.rows[0],
      message: "Predicción guardada"
    });
  } catch (error) {
    next(error);
  }
});
