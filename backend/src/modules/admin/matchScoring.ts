import { Router } from "express";
import { z } from "zod";
import { requireAdmin, requireAuth } from "../../middlewares/auth.js";
import { getMatchScoringBreakdown } from "../matches/matchScoringBreakdown.js";

export const adminMatchScoringRouter = Router();
adminMatchScoringRouter.use(requireAuth, requireAdmin);

adminMatchScoringRouter.get("/matches/:id/scoring", async (req, res, next) => {
  try {
    const matchId = z.coerce.number().int().positive().parse(req.params.id);
    const data = await getMatchScoringBreakdown(matchId);
    if (!data) {
      res.status(404).json({ message: "Partido no encontrado" });
      return;
    }
    res.json(data);
  } catch (error) {
    next(error);
  }
});
