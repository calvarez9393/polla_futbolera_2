import type { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import type { SignOptions } from "jsonwebtoken";
import { env } from "../config/env.js";
import type { AuthUser } from "../types/auth.js";

interface TokenPayload {
  sub: string;
  email: string;
  role: "USER" | "ADMIN";
}

export function requireAuth(req: Request, res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith("Bearer ")) {
    res.status(401).json({ message: "Token requerido" });
    return;
  }

  try {
    const token = authHeader.replace("Bearer ", "");
    const payload = jwt.verify(token, env.JWT_SECRET) as TokenPayload;
    req.user = { id: Number(payload.sub), email: payload.email, role: payload.role };
    next();
  } catch {
    res.status(401).json({ message: "Token inválido" });
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
