/** Definición ordenada de reglas para el panel admin (etiquetas en español). */

export interface ScoringRuleField {
  key: string;
  label: string;
  hint?: string;
}

export interface ScoringRuleSection {
  title: string;
  description?: string;
  fields: ScoringRuleField[];
}

export const SCORING_RULE_SECTIONS: ScoringRuleSection[] = [
  {
    title: "Fase 1 — Pronóstico por partido",
    description: "Grupos y dieciseisavos de final. Los puntos de un mismo partido se suman.",
    fields: [
      { key: "outcome_points", label: "Acertar ganador", hint: "Victoria local o visitante" },
      { key: "draw_points", label: "Acertar empate", hint: "Cuando el resultado real es empate" },
      { key: "goal_diff_points", label: "Acertar diferencia de goles", hint: "Misma diferencia apuntando al mismo ganador; los empates también suman" },
      { key: "exact_score_points", label: "Acertar marcador exacto", hint: "Mismo resultado final" }
    ]
  },
  {
    title: "Fase 1 — Clasificados",
    description: "Antes del mundial: 24 equipos que avanzan de grupos.",
    fields: [
      {
        key: "qualified_team_points",
        label: "Cada clasificado correcto",
        hint: "4 pts × cantidad de aciertos (máx. 24 equipos)"
      }
    ]
  },
  {
    title: "Fase 1 — Bonificaciones",
    fields: [
      {
        key: "expert_day_bonus",
        label: "Bono experto del día",
        hint: "Por cada jornada: acertar el 1X2 en todos los partidos de Fase 1 de ese día"
      },
      { key: "invicto_bonus", label: "Bono invicto", hint: "10 resultados seguidos acertados" },
      { key: "group_master_bonus", label: "Bono maestro de grupo", hint: "Los 2 clasificados correctos del mismo grupo" }
    ]
  },
  {
    title: "Fase 2 — Octavos de final",
    description: "Además se suman ganador/empate y diferencia de goles con los valores de Fase 1.",
    fields: [
      { key: "r8_advance_points", label: "Equipo que avanza", hint: "Quién pasa de ronda" },
      { key: "r8_exact_points", label: "Marcador exacto", hint: "Goles local y visitante" }
    ]
  },
  {
    title: "Fase 2 — Cuartos de final",
    fields: [
      { key: "r4_advance_points", label: "Equipo que avanza" },
      { key: "r4_exact_points", label: "Marcador exacto" }
    ]
  },
  {
    title: "Fase 2 — Semifinales",
    fields: [
      { key: "sf_advance_points", label: "Equipo que avanza" },
      { key: "sf_exact_points", label: "Marcador exacto" }
    ]
  },
  {
    title: "Fase 2 — Final y tercer puesto",
    fields: [
      { key: "final_advance_points", label: "Campeón del partido / quien avanza" },
      { key: "final_exact_points", label: "Marcador exacto (final o 3.er puesto)" }
    ]
  },
  {
    title: "Fase 2 — Cuadro (antes de octavos)",
    description: "Predicción del cuadro completo; topes donde indica máximo.",
    fields: [
      { key: "semifinalist_points", label: "Cada semifinalista correcto" },
      { key: "semifinalist_max_points", label: "Tope puntos semifinalistas", hint: "Máx. 40 (4 equipos)" },
      { key: "finalist_points", label: "Cada finalista correcto" },
      { key: "finalist_max_points", label: "Tope puntos finalistas", hint: "Máx. 40 (2 equipos)" },
      { key: "champion_points", label: "Campeón del mundial" },
      { key: "runner_up_points", label: "Subcampeón" },
      { key: "third_place_points", label: "Tercer puesto" }
    ]
  },
  {
    title: "Premios especiales",
    fields: [
      { key: "top_scorer_points", label: "Goleador del mundial" },
      { key: "top_assister_points", label: "Máximo asistidor" }
    ]
  }
];

export const ALL_SCORING_RULE_KEYS = SCORING_RULE_SECTIONS.flatMap((s) => s.fields.map((f) => f.key));

export const DEFAULT_SCORING_RULE_VALUES: Record<string, number> = {
  exact_score_points: 5,
  outcome_points: 3,
  draw_points: 3,
  goal_diff_points: 2,
  qualified_team_points: 4,
  r8_advance_points: 8,
  r8_exact_points: 5,
  r4_advance_points: 12,
  r4_exact_points: 7,
  sf_advance_points: 18,
  sf_exact_points: 10,
  final_advance_points: 40,
  final_exact_points: 15,
  champion_points: 40,
  runner_up_points: 20,
  third_place_points: 15,
  top_scorer_points: 25,
  top_assister_points: 20,
  semifinalist_points: 10,
  semifinalist_max_points: 40,
  finalist_points: 20,
  finalist_max_points: 40,
  group_master_bonus: 5,
  expert_day_bonus: 10,
  invicto_bonus: 15
};

export function mergeScoringRulesFromApi(raw: Record<string, unknown>): Record<string, number> {
  const merged = { ...DEFAULT_SCORING_RULE_VALUES };
  for (const key of ALL_SCORING_RULE_KEYS) {
    const v = raw[key];
    if (typeof v === "number" && !Number.isNaN(v)) merged[key] = v;
    else if (typeof v === "string" && v !== "") merged[key] = Number(v);
  }
  return merged;
}

export function scoringRulesPayload(rules: Record<string, number>): Record<string, number> {
  const payload: Record<string, number> = {};
  for (const key of ALL_SCORING_RULE_KEYS) {
    payload[key] = rules[key] ?? DEFAULT_SCORING_RULE_VALUES[key] ?? 0;
  }
  return payload;
}
