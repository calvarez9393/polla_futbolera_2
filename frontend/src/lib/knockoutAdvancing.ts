export const KNOCKOUT_ROUND_KEYS = new Set(["R16", "R8", "R4", "SF", "F", "TP3"]);

export function isKnockoutRound(roundKey?: string | null): boolean {
  return roundKey != null && KNOCKOUT_ROUND_KEYS.has(roundKey);
}

export function isGroupMatch(stage?: string | null, roundKey?: string | null): boolean {
  return stage === "GROUP" || roundKey === "GROUP";
}

export function isPhase1Match(stage?: string | null, roundKey?: string | null): boolean {
  if (isGroupMatch(stage, roundKey)) return true;
  return roundKey === "R16";
}

/** Solo octavos en adelante exigen ganador en empate al predecir. */
export function requiresAdvancingOnDraw(stage?: string | null, roundKey?: string | null): boolean {
  if (isGroupMatch(stage, roundKey)) return false;
  if (roundKey === "R16") return false;
  return stage === "KNOCKOUT" || isKnockoutRound(roundKey);
}

/** UI de avance de ronda (banner, selector en empate). */
export function showsKnockoutAdvancingUi(stage?: string | null, roundKey?: string | null): boolean {
  if (isGroupMatch(stage, roundKey)) return false;
  return stage === "KNOCKOUT" || isKnockoutRound(roundKey);
}

/** Texto de la fase a la que avanza el ganador del cruce. */
export function nextRoundLabel(roundKey?: string | null): string {
  switch (roundKey) {
    case "R16":
      return "octavos de final";
    case "R8":
      return "cuartos de final";
    case "R4":
      return "semifinal";
    case "SF":
      return "la final";
    case "F":
      return "el campeonato";
    case "TP3":
      return "3.er puesto";
    default:
      return "siguiente ronda";
  }
}

export function advancingTeamIdFromScores(
  homeScore: number,
  awayScore: number,
  homeTeamId?: number,
  awayTeamId?: number
): number | null {
  if (homeScore > awayScore && homeTeamId) return homeTeamId;
  if (awayScore > homeScore && awayTeamId) return awayTeamId;
  return null;
}
