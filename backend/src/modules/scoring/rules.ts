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

function goalDifference(home: number, away: number): number {
  return Math.abs(home - away);
}

/** Fase 1: grupos y dieciseisavos — ganador/empate, diferencia, marcador exacto */
function computePhase1MatchPoints(
  predictedHome: number,
  predictedAway: number,
  realHome: number,
  realAway: number,
  rules: OfficialScoringRules
): { points: number; breakdown: Record<string, number> } {
  let points = 0;
  const breakdown: Record<string, number> = {};

  const exact = predictedHome === realHome && predictedAway === realAway;
  const predOutcome = getOutcome(predictedHome, predictedAway);
  const realOutcome = getOutcome(realHome, realAway);
  const sameGoalDiff =
    goalDifference(predictedHome, predictedAway) === goalDifference(realHome, realAway);

  if (exact) {
    points += rules.exact_score_points;
    breakdown.exactScore = rules.exact_score_points;
  }

  if (predOutcome === realOutcome) {
    if (realOutcome === "DRAW") {
      points += rules.draw_points;
      breakdown.draw = rules.draw_points;
    } else {
      points += rules.outcome_points;
      breakdown.winner = rules.outcome_points;
    }
  }

  // En empate exacto no se suma diferencia de goles (reglamento: empate +5 = 8 pts)
  if (sameGoalDiff && !(exact && realOutcome === "DRAW")) {
    points += rules.goal_diff_points;
    breakdown.goalDiff = rules.goal_diff_points;
  }

  return { points, breakdown };
}

/** Fase 2: octavos en adelante — equipo que avanza + marcador exacto */
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
  let points = 0;
  const breakdown: Record<string, number> = {};
  const { advance, exact } = getKnockoutRoundPoints(roundKey, rules);

  if (predictedHome === realHome && predictedAway === realAway) {
    points += exact;
    breakdown.exactScore = exact;
  }

  if (
    predictedAdvancingTeamId &&
    winnerTeamId &&
    predictedAdvancingTeamId === winnerTeamId
  ) {
    points += advance;
    breakdown.advancing = advance;
  }

  return { points, breakdown };
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
