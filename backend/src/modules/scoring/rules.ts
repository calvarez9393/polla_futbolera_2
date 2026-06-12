import {
  getKnockoutRoundPoints,
  isPhase1Round,
  resolveRoundKey,
  type OfficialScoringRules,
  type RoundKey
} from "./rulesConfig.js";

function getOutcome(home: number, away: number): "HOME" | "AWAY" | "DRAW" {
  if (home === away) return "DRAW";
  return home > away ? "HOME" : "AWAY";
}

/** Diferencia con signo: solo coincide si el resultado apunta al mismo ganador (o ambos empatan). */
function goalDifference(home: number, away: number): number {
  return home - away;
}

/** Ganador/empate y diferencia de goles (comunes a todas las rondas). */
function computeOutcomeAndDiffPoints(
  predictedHome: number,
  predictedAway: number,
  realHome: number,
  realAway: number,
  rules: OfficialScoringRules
): { points: number; breakdown: Record<string, number> } {
  let points = 0;
  const breakdown: Record<string, number> = {};

  const predOutcome = getOutcome(predictedHome, predictedAway);
  const realOutcome = getOutcome(realHome, realAway);
  const sameGoalDiff =
    goalDifference(predictedHome, predictedAway) === goalDifference(realHome, realAway);

  if (predOutcome === realOutcome) {
    if (realOutcome === "DRAW") {
      points += rules.draw_points;
      breakdown.draw = rules.draw_points;
    } else {
      points += rules.outcome_points;
      breakdown.winner = rules.outcome_points;
    }
  }

  // El empate (exacto o no) también suma diferencia de goles, igual que acertar al ganador.
  if (sameGoalDiff) {
    points += rules.goal_diff_points;
    breakdown.goalDiff = rules.goal_diff_points;
  }

  return { points, breakdown };
}

/** Fase 1: grupos y dieciseisavos — ganador/empate, diferencia, marcador exacto */
function computePhase1MatchPoints(
  predictedHome: number,
  predictedAway: number,
  realHome: number,
  realAway: number,
  rules: OfficialScoringRules
): { points: number; breakdown: Record<string, number> } {
  const base = computeOutcomeAndDiffPoints(predictedHome, predictedAway, realHome, realAway, rules);
  let points = base.points;
  const breakdown = base.breakdown;

  if (predictedHome === realHome && predictedAway === realAway) {
    points += rules.exact_score_points;
    breakdown.exactScore = rules.exact_score_points;
  }

  return { points, breakdown };
}

/** Fase 2: octavos en adelante — ganador/empate y diferencia como en fase 1, más marcador exacto de la ronda y equipo que avanza. */
function computePhase2MatchPoints(
  predictedHome: number,
  predictedAway: number,
  realHome: number,
  realAway: number,
  roundKey: RoundKey,
  predictedAdvancingTeamId: number | null | undefined,
  winnerTeamId: number | null | undefined,
  rules: OfficialScoringRules
): { points: number; breakdown: Record<string, number> } {
  const base = computeOutcomeAndDiffPoints(predictedHome, predictedAway, realHome, realAway, rules);
  let points = base.points;
  const breakdown = base.breakdown;
  const { advance, exact } = getKnockoutRoundPoints(roundKey, rules);

  if (predictedHome === realHome && predictedAway === realAway) {
    points += exact;
    breakdown.exactScore = exact;
  }

  if (
    predictedAdvancingTeamId &&
    winnerTeamId &&
    Number(predictedAdvancingTeamId) === Number(winnerTeamId)
  ) {
    points += advance;
    breakdown.advancing = advance;
  }

  return { points, breakdown };
}

/** Cruce predicho distinto al oficial: solo puntúa el avance si el elegido del usuario es el ganador real. */
export function computeAdvanceOnlyPoints(args: {
  roundKey?: string | null;
  stage?: string;
  roundLabel?: string | null;
  predictedAdvancingTeamId: number | null | undefined;
  winnerTeamId: number | null | undefined;
  rules: OfficialScoringRules;
}): { points: number; breakdown: Record<string, number> } | null {
  const roundKey = resolveRoundKey({
    round_key: args.roundKey,
    stage: args.stage,
    round_label: args.roundLabel
  });
  const { advance } = getKnockoutRoundPoints(roundKey, args.rules);
  if (
    advance > 0 &&
    args.predictedAdvancingTeamId != null &&
    args.winnerTeamId != null &&
    Number(args.predictedAdvancingTeamId) === Number(args.winnerTeamId)
  ) {
    return { points: advance, breakdown: { advancing: advance } };
  }
  return null;
}

export function computePredictionPoints(args: {
  predictedHome: number;
  predictedAway: number;
  realHome: number;
  realAway: number;
  roundKey?: string | null;
  stage?: string;
  roundLabel?: string | null;
  predictedAdvancingTeamId?: number | null;
  winnerTeamId?: number | null;
  rules: OfficialScoringRules;
}): { points: number; breakdown: Record<string, number> } {
  const roundKey = resolveRoundKey({
    round_key: args.roundKey,
    stage: args.stage,
    round_label: args.roundLabel
  });

  if (isPhase1Round(roundKey)) {
    return computePhase1MatchPoints(
      args.predictedHome,
      args.predictedAway,
      args.realHome,
      args.realAway,
      args.rules
    );
  }

  return computePhase2MatchPoints(
    args.predictedHome,
    args.predictedAway,
    args.realHome,
    args.realAway,
    roundKey,
    args.predictedAdvancingTeamId,
    args.winnerTeamId,
    args.rules
  );
}
