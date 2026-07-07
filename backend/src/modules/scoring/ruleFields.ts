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

// El SET de columnas se genera desde el MISMO RULE_KEYS que arma los parámetros, para que la
// posición de cada $n siempre coincida con su columna. (Antes estaban escritos a mano en distinto
// orden y desalineaban los puntos de Fase 2 al guardar.)
export const SCORING_RULE_UPDATE_SQL = RULE_KEYS.map(
  (key, index) => `${key} = $${index + 1}`
).join(",\n  ");
