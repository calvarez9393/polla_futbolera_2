import { Router } from "express";
import { fetchLeaderboard } from "./stats.js";

export const leaderboardRouter = Router();

leaderboardRouter.get("/", async (_req, res, next) => {
  try {
    const rows = await fetchLeaderboard(false);
    res.json(rows);
  } catch (error) {
    next(error);
  }
});
