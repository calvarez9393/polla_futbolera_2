import { DEFAULT_OFFICIAL_RULES, type OfficialScoringRules } from "./rulesConfig.js";

const RULE_KEYS = Object.keys(DEFAULT_OFFICIAL_RULES) as (keyof OfficialScoringRules)[];

export function pickScoringRulesRow(row: Record<string, unknown>): OfficialScoringRules {
  const result = { ...DEFAULT_OFFICIAL_RULES };
  for (const key of RULE_KEYS) {
    const v = row[key];
    if (typeof v === "number" && !Number.isNaN(v)) {
      result[key] = v;
    }
  }
  return result;
}

export function scoringRulesToDbParams(rules: OfficialScoringRules): unknown[] {
  return RULE_KEYS.map((k) => rules[k]);
}

export const SCORING_RULE_UPDATE_SQL = `
  exact_score_points = $1,
  outcome_points = $2,
  draw_points = $3,
  goal_diff_points = $4,
  qualified_team_points = $5,
  r8_advance_points = $6,
  r8_exact_points = $7,
  r4_advance_points = $8,
  r4_exact_points = $9,
  sf_advance_points = $10,
  sf_exact_points = $11,
  final_advance_points = $12,
  final_exact_points = $13,
  champion_points = $14,
  runner_up_points = $15,
  third_place_points = $16,
  top_scorer_points = $17,
  top_assister_points = $18,
  semifinalist_points = $19,
  semifinalist_max_points = $20,
  finalist_points = $21,
  finalist_max_points = $22,
  group_master_bonus = $23,
  expert_day_bonus = $24,
  invicto_bonus = $25`;
