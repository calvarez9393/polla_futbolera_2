import { Router } from "express";
import { z } from "zod";
import { fetchLeaderboard } from "./stats.js";
import { fetchUserScores, isLeaderboardParticipant } from "./userScores.js";

export const leaderboardRouter = Router();

const userIdParamSchema = z.object({
  userId: z.coerce.number().int().positive()
});

leaderboardRouter.get("/", async (_req, res, next) => {
  try {
    const rows = await fetchLeaderboard(false);
    res.json(rows);
  } catch (error) {
    next(error);
  }
});

leaderboardRouter.get("/:userId/scores", async (req, res, next) => {
  try {
    const parsed = userIdParamSchema.safeParse(req.params);
    if (!parsed.success) {
      res.status(400).json({ message: "Usuario inválido" });
      return;
    }
    const { userId } = parsed.data;
    if (!(await isLeaderboardParticipant(userId))) {
      res.status(404).json({ message: "Jugador no encontrado" });
      return;
    }
    res.json(await fetchUserScores(userId));
  } catch (error) {
    next(error);
  }
});
