import { Router } from "express";
import { z } from "zod";
import { resetCompetitionData } from "./resetCompetition.js";

export const adminCompetitionRouter = Router();

const resetBodySchema = z.object({
  confirm: z.literal(true)
});

adminCompetitionRouter.post("/reset", async (req, res, next) => {
  try {
    resetBodySchema.parse(req.body);
    const result = await resetCompetitionData();
    res.json({
      ok: true,
      message: "Partidos, predicciones y ranking reiniciados",
      ...result
    });
  } catch (error) {
    next(error);
  }
});
