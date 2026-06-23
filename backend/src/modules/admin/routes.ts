import { Router } from "express";
import { z } from "zod";
import { pool } from "../../db/pool.js";
import { requireAdmin, requireAuth } from "../../middlewares/auth.js";
import { runSync } from "../sync/service.js";
import { adminMatchesRouter } from "./matches.js";
import { adminUsersRouter } from "./users.js";
import { adminCalendarRouter } from "./calendar.js";
import { adminCompetitionRouter } from "./competition.js";
import { adminScoringRouter } from "./scoring.js";
import { adminMatchScoringRouter } from "./matchScoring.js";
import { adminKnockoutCompletionRouter } from "./knockoutCompletion.js";
import { pickScoringRulesRow, scoringRulesToDbParams, SCORING_RULE_UPDATE_SQL } from "../scoring/ruleFields.js";
import { DEFAULT_OFFICIAL_RULES } from "../scoring/rulesConfig.js";

const scoringSchema = z.object({
  exact_score_points: z.number().int().min(0),
  outcome_points: z.number().int().min(0),
  draw_points: z.number().int().min(0),
  goal_diff_points: z.number().int().min(0),
  qualified_team_points: z.number().int().min(0),
  r8_advance_points: z.number().int().min(0),
  r8_exact_points: z.number().int().min(0),
  r4_advance_points: z.number().int().min(0),
  r4_exact_points: z.number().int().min(0),
  sf_advance_points: z.number().int().min(0),
  sf_exact_points: z.number().int().min(0),
  final_advance_points: z.number().int().min(0),
  final_exact_points: z.number().int().min(0),
  champion_points: z.number().int().min(0),
  runner_up_points: z.number().int().min(0),
  third_place_points: z.number().int().min(0),
  top_scorer_points: z.number().int().min(0),
  top_assister_points: z.number().int().min(0),
  semifinalist_points: z.number().int().min(0),
  semifinalist_max_points: z.number().int().min(0),
  finalist_points: z.number().int().min(0),
  finalist_max_points: z.number().int().min(0),
  group_master_bonus: z.number().int().min(0),
  expert_day_bonus: z.number().int().min(0),
  invicto_bonus: z.number().int().min(0)
});

export const adminRouter = Router();
adminRouter.use(requireAuth, requireAdmin);
adminRouter.use(adminMatchesRouter);
adminRouter.use(adminScoringRouter);
adminRouter.use(adminMatchScoringRouter);
adminRouter.use(adminKnockoutCompletionRouter);
adminRouter.use("/users", adminUsersRouter);
adminRouter.use(adminCalendarRouter);
adminRouter.use("/competition", adminCompetitionRouter);

adminRouter.get("/scoring-rules", async (_req, res, next) => {
  try {
    const result = await pool.query("SELECT * FROM scoring_rules WHERE id = 1");
    if (!result.rows[0]) {
      res.json(DEFAULT_OFFICIAL_RULES);
      return;
    }
    res.json(pickScoringRulesRow(result.rows[0]));
  } catch (error) {
    next(error);
  }
});

adminRouter.put("/scoring-rules", async (req, res, next) => {
  try {
    const input = scoringSchema.parse(req.body);
    const merged = { ...DEFAULT_OFFICIAL_RULES, ...input };
    const result = await pool.query(
      `UPDATE scoring_rules SET ${SCORING_RULE_UPDATE_SQL}, updated_at = NOW() WHERE id = 1 RETURNING *`,
      scoringRulesToDbParams(merged)
    );
    res.json(pickScoringRulesRow(result.rows[0]));
  } catch (error) {
    next(error);
  }
});

adminRouter.post("/sync-api", async (_req, res, next) => {
  try {
    await runSync("manual");
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});
