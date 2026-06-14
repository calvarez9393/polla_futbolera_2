import type { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import type { SignOptions } from "jsonwebtoken";
import { env } from "../config/env.js";
import { pool } from "../db/pool.js";
import type { AuthUser } from "../types/auth.js";

interface TokenPayload {
  sub: string;
  email: string;
  role: "USER" | "ADMIN";
}

export async function requireAuth(req: Request, res: Response, next: NextFunction): Promise<void> {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith("Bearer ")) {
    res.status(401).json({ message: "Token requerido" });
    return;
  }

  let payload: TokenPayload;
  try {
    const token = authHeader.replace("Bearer ", "");
    payload = jwt.verify(token, env.JWT_SECRET) as TokenPayload;
  } catch {
    res.status(401).json({ message: "Token inválido" });
    return;
  }

  try {
    const userId = Number(payload.sub);
    const result = await pool.query("SELECT is_active FROM users WHERE id = $1", [userId]);
    const account = result.rows[0];
    if (!account?.is_active) {
      res.status(403).json({
        message: "Tu cuenta está desactivada. Contacta al administrador de la polla.",
        code: "ACCOUNT_DISABLED"
      });
      return;
    }
    req.user = { id: userId, email: payload.email, role: payload.role };
    next();
  } catch (error) {
    next(error);
  }
}

export function requireAdmin(req: Request, res: Response, next: NextFunction): void {
  if (!req.user || req.user.role !== "ADMIN") {
    res.status(403).json({ message: "Acceso denegado" });
    return;
  }
  next();
}

export function signToken(user: AuthUser): string {
  const options: SignOptions = {
    subject: String(user.id),
    expiresIn: env.JWT_EXPIRES_IN as SignOptions["expiresIn"]
  };
  return jwt.sign({ email: user.email, role: user.role }, env.JWT_SECRET, {
    ...options
  });
}
