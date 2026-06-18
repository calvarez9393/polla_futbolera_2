import { Router } from "express";
import bcrypt from "bcrypt";
import { z } from "zod";
import { pool } from "../../db/pool.js";
import { requireAdmin, requireAuth } from "../../middlewares/auth.js";

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
  password: z.string().min(6).optional(),
  isActive: z.boolean().optional(),
  lateStartPoints: z.number().int().min(0).max(100000).optional()
});

const adminPredictionSchema = z.object({
  matchId: z.coerce.number().int().positive(),
  predictedHomeScore: z.coerce.number().int().min(0),
  predictedAwayScore: z.coerce.number().int().min(0)
});

function buildUserUpdateSets(input: z.infer<typeof updateUserSchema>): {
  sets: string[];
  params: unknown[];
} {
  const sets: string[] = [];
  const params: unknown[] = [];
  const columns: Array<[unknown, string]> = [
    [input.displayName, "display_name"],
    [input.amountPaid, "amount_paid"],
    [input.paymentNotes, "payment_notes"],
    [input.isActive, "is_active"]
  ];
  for (const [value, column] of columns) {
    if (value !== undefined) {
      params.push(value);
      sets.push(`${column} = $${params.length}`);
    }
  }
  return { sets, params };
}

async function applyLateStartPoints(userId: number, points: number): Promise<void> {
  if (points > 0) {
    await pool.query(
      `INSERT INTO prediction_scores (user_id, source_type, source_id, points, breakdown)
      VALUES ($1, 'LATE_START', 0, $2, '{}'::jsonb)
      ON CONFLICT (user_id, source_type, source_id)
      DO UPDATE SET points = EXCLUDED.points, updated_at = NOW()`,
      [userId, points]
    );
  } else {
    await pool.query(
      `DELETE FROM prediction_scores WHERE user_id = $1 AND source_type = 'LATE_START' AND source_id = 0`,
      [userId]
    );
  }
}

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
        u.is_active,
        u.created_at,
        COALESCE(SUM(ps.points), 0)::int AS total_points,
        COALESCE(MAX(ps.points) FILTER (WHERE ps.source_type = 'LATE_START' AND ps.source_id = 0), 0)::int AS late_start_points,
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
        isActive: row.is_active,
        createdAt: row.created_at,
        totalPoints: row.total_points,
        lateStartPoints: row.late_start_points,
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
      RETURNING id, email, display_name, role, amount_paid, payment_notes, is_active, created_at`,
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
      isActive: row.is_active,
      createdAt: row.created_at,
      totalPoints: 0,
      lateStartPoints: 0,
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

    if (input.isActive === false) {
      const target = await pool.query("SELECT role FROM users WHERE id = $1", [userId]);
      if (!target.rows[0]) {
        res.status(404).json({ message: "Usuario no encontrado" });
        return;
      }
      if (target.rows[0].role === "ADMIN") {
        res.status(400).json({ message: "No puedes desactivar a un administrador" });
        return;
      }
    }

    if (input.password) {
      const passwordHash = await bcrypt.hash(input.password, 10);
      await pool.query("UPDATE users SET password_hash = $1 WHERE id = $2", [passwordHash, userId]);
    }

    if (input.lateStartPoints !== undefined) {
      await applyLateStartPoints(userId, input.lateStartPoints);
    }

    const { sets, params } = buildUserUpdateSets(input);

    if (sets.length === 0 && !input.password && input.lateStartPoints === undefined) {
      res.status(400).json({ message: "Nada que actualizar" });
      return;
    }

    let result;
    if (sets.length > 0) {
      params.push(userId);
      result = await pool.query(
        `UPDATE users SET ${sets.join(", ")} WHERE id = $${params.length}
        RETURNING id, email, display_name, role, amount_paid, payment_notes, is_active, created_at`,
        params
      );
    } else {
      result = await pool.query(
        "SELECT id, email, display_name, role, amount_paid, payment_notes, is_active, created_at FROM users WHERE id = $1",
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
        COALESCE(SUM(points) FILTER (WHERE source_type = 'LATE_START' AND source_id = 0), 0)::int AS late_start_points,
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
      isActive: row.is_active,
      createdAt: row.created_at,
      totalPoints: stats.rows[0].total_points,
      lateStartPoints: stats.rows[0].late_start_points,
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

    // El admin puede modificar el marcador mientras el partido no haya finalizado
    // (incluso si ya empezó o si ya pasó el cierre de pronósticos).
    if (match.status === "FINISHED") {
      res.status(400).json({ message: "No puedes modificar el marcador de un partido finalizado" });
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

// Marcador de solo escritura: registra un pronóstico para el usuario únicamente si
// no existe uno previo. Nunca sobrescribe (a diferencia del PUT de arriba).
adminUsersRouter.post("/:userId/predictions", async (req, res, next) => {
  try {
    const userId = Number(req.params.userId);
    const input = adminPredictionSchema.parse(req.body);

    const user = await pool.query("SELECT id FROM users WHERE id = $1", [userId]);
    if (!user.rows[0]) {
      res.status(404).json({ message: "Usuario no encontrado" });
      return;
    }

    const matchResult = await pool.query("SELECT id FROM matches WHERE id = $1", [input.matchId]);
    if (!matchResult.rows[0]) {
      res.status(404).json({ message: "Partido no encontrado" });
      return;
    }

    const result = await pool.query(
      `INSERT INTO predictions (user_id, match_id, predicted_home_score, predicted_away_score)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (user_id, match_id) DO NOTHING
      RETURNING *`,
      [userId, input.matchId, input.predictedHomeScore, input.predictedAwayScore]
    );

    if (!result.rows[0]) {
      res.status(409).json({
        message: "El usuario ya tiene un marcador para este partido; solo se puede poner, no cambiar."
      });
      return;
    }

    res.status(201).json({
      prediction: result.rows[0],
      message: "Marcador guardado"
    });
  } catch (error) {
    next(error);
  }
});
