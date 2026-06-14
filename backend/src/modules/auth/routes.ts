import { Router } from "express";
import bcrypt from "bcrypt";
import { z } from "zod";
import { pool } from "../../db/pool.js";
import { signToken } from "../../middlewares/auth.js";
import { loginIdentifierSchema, normalizeLoginIdentifier } from "../../utils/loginIdentifier.js";

const loginSchema = z.object({
  login: loginIdentifierSchema,
  password: z.string().min(6)
});

export const authRouter = Router();

authRouter.post("/register", (_req, res) => {
  res.status(403).json({
    message: "El registro público está deshabilitado. Solicita acceso al administrador de la polla."
  });
});

authRouter.post("/login", async (req, res, next) => {
  try {
    const input = loginSchema.parse(req.body);
    const login = normalizeLoginIdentifier(input.login);
    const result = await pool.query(
      "SELECT id, email, role, password_hash, is_active FROM users WHERE email = $1",
      [login]
    );
    const user = result.rows[0];
    if (!user) {
      res.status(401).json({ message: "Credenciales inválidas" });
      return;
    }

    const valid = await bcrypt.compare(input.password, user.password_hash);
    if (!valid) {
      res.status(401).json({ message: "Credenciales inválidas" });
      return;
    }

    if (!user.is_active) {
      res.status(403).json({ message: "Tu cuenta está desactivada. Contacta al administrador de la polla." });
      return;
    }

    res.json({
      token: signToken({ id: user.id, email: user.email, role: user.role }),
      user: { id: user.id, email: user.email, role: user.role }
    });
  } catch (error) {
    next(error);
  }
});
