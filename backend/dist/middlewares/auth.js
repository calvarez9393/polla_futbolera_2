import jwt from "jsonwebtoken";
import { env } from "../config/env.js";
export function requireAuth(req, res, next) {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith("Bearer ")) {
        res.status(401).json({ message: "Token requerido" });
        return;
    }
    try {
        const token = authHeader.replace("Bearer ", "");
        const payload = jwt.verify(token, env.JWT_SECRET);
        req.user = { id: Number(payload.sub), email: payload.email, role: payload.role };
        next();
    }
    catch {
        res.status(401).json({ message: "Token inválido" });
    }
}
export function requireAdmin(req, res, next) {
    if (!req.user || req.user.role !== "ADMIN") {
        res.status(403).json({ message: "Acceso denegado" });
        return;
    }
    next();
}
export function signToken(user) {
    const options = {
        subject: String(user.id),
        expiresIn: env.JWT_EXPIRES_IN
    };
    return jwt.sign({ email: user.email, role: user.role }, env.JWT_SECRET, {
        ...options
    });
}
