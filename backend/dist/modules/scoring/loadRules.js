import { pool } from "../../db/pool.js";
import { DEFAULT_OFFICIAL_RULES } from "./rulesConfig.js";
export async function loadOfficialScoringRules() {
    const result = await pool.query("SELECT * FROM scoring_rules WHERE id = 1");
    const row = result.rows[0];
    if (!row)
        return DEFAULT_OFFICIAL_RULES;
    return {
        exact_score_points: row.exact_score_points ?? DEFAULT_OFFICIAL_RULES.exact_score_points,
        outcome_points: row.outcome_points ?? DEFAULT_OFFICIAL_RULES.outcome_points,
        draw_points: row.draw_points ?? DEFAULT_OFFICIAL_RULES.draw_points,
        goal_diff_points: row.goal_diff_points ?? DEFAULT_OFFICIAL_RULES.goal_diff_points,
        r8_advance_points: row.r8_advance_points ?? DEFAULT_OFFICIAL_RULES.r8_advance_points,
        r8_exact_points: row.r8_exact_points ?? DEFAULT_OFFICIAL_RULES.r8_exact_points,
        r4_advance_points: row.r4_advance_points ?? DEFAULT_OFFICIAL_RULES.r4_advance_points,
        r4_exact_points: row.r4_exact_points ?? DEFAULT_OFFICIAL_RULES.r4_exact_points,
        sf_advance_points: row.sf_advance_points ?? DEFAULT_OFFICIAL_RULES.sf_advance_points,
        sf_exact_points: row.sf_exact_points ?? DEFAULT_OFFICIAL_RULES.sf_exact_points,
        final_advance_points: row.final_advance_points ?? DEFAULT_OFFICIAL_RULES.final_advance_points,
        final_exact_points: row.final_exact_points ?? DEFAULT_OFFICIAL_RULES.final_exact_points,
        qualified_team_points: row.qualified_team_points ?? DEFAULT_OFFICIAL_RULES.qualified_team_points,
        champion_points: row.champion_points ?? DEFAULT_OFFICIAL_RULES.champion_points,
        runner_up_points: row.runner_up_points ?? DEFAULT_OFFICIAL_RULES.runner_up_points,
        third_place_points: row.third_place_points ?? DEFAULT_OFFICIAL_RULES.third_place_points,
        top_scorer_points: row.top_scorer_points ?? DEFAULT_OFFICIAL_RULES.top_scorer_points,
        top_assister_points: row.top_assister_points ?? DEFAULT_OFFICIAL_RULES.top_assister_points,
        semifinalist_points: row.semifinalist_points ?? DEFAULT_OFFICIAL_RULES.semifinalist_points,
        semifinalist_max_points: row.semifinalist_max_points ?? DEFAULT_OFFICIAL_RULES.semifinalist_max_points,
        finalist_points: row.finalist_points ?? DEFAULT_OFFICIAL_RULES.finalist_points,
        finalist_max_points: row.finalist_max_points ?? DEFAULT_OFFICIAL_RULES.finalist_max_points,
        group_master_bonus: row.group_master_bonus ?? DEFAULT_OFFICIAL_RULES.group_master_bonus,
        expert_day_bonus: row.expert_day_bonus ?? DEFAULT_OFFICIAL_RULES.expert_day_bonus,
        invicto_bonus: row.invicto_bonus ?? DEFAULT_OFFICIAL_RULES.invicto_bonus
    };
}
