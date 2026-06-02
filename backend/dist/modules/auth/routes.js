import { Router } from "express";
import bcrypt from "bcrypt";
import { z } from "zod";
import { pool } from "../../db/pool.js";
import { signToken } from "../../middlewares/auth.js";
const authSchema = z.object({
    email: z.string().email(),
    password: z.string().min(6)
});
export const authRouter = Router();
authRouter.post("/register", async (req, res, next) => {
    try {
        const input = authSchema.parse(req.body);
        const passwordHash = await bcrypt.hash(input.password, 10);
        const role = (await pool.query("SELECT COUNT(*)::int AS count FROM users")).rows[0].count === 0 ? "ADMIN" : "USER";
        const result = await pool.query("INSERT INTO users (email, password_hash, role) VALUES ($1, $2, $3) RETURNING id, email, role", [input.email.toLowerCase(), passwordHash, role]);
        const user = result.rows[0];
        res.status(201).json({ token: signToken(user), user });
    }
    catch (error) {
        next(error);
    }
});
authRouter.post("/login", async (req, res, next) => {
    try {
        const input = authSchema.parse(req.body);
        const result = await pool.query("SELECT id, email, role, password_hash FROM users WHERE email = $1", [
            input.email.toLowerCase()
        ]);
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
        res.json({
            token: signToken({ id: user.id, email: user.email, role: user.role }),
            user: { id: user.id, email: user.email, role: user.role }
        });
    }
    catch (error) {
        next(error);
    }
});
