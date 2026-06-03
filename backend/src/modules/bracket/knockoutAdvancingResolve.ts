import {
  knockoutExternalNum,
  matchOutcomeFromPrediction,
  matchOutcomeOfficial,
  resolveKnockoutBracketTeams,
  type KnockoutMatchRow,
  type UserPredictionRow
} from "./knockoutBracketLogic.js";

/** Quién avanza según el cuadro predicho del usuario (equipos ya resueltos de su bracket). */
export function resolveKnockoutAdvancingTeamId(
  match: KnockoutMatchRow,
  prediction: UserPredictionRow | null | undefined,
  homeTeamId: number,
  awayTeamId: number,
  tbdId: number
): number | null {
  return matchOutcomeFromPrediction(prediction, homeTeamId, awayTeamId, tbdId).winnerId;
}

/** Quién avanzó según resultado oficial. */
export function resolveOfficialKnockoutAdvancingTeamId(
  match: KnockoutMatchRow,
  homeTeamId: number,
  awayTeamId: number,
  tbdId: number
): number | null {
  return matchOutcomeOfficial(match, homeTeamId, awayTeamId, tbdId).winnerId;
}

export function resolvePredictionAdvancingTeamId(
  match: { stage?: string; home_team_id: number; away_team_id: number },
  predictedHome: number,
  predictedAway: number,
  predictedAdvancingTeamId: number | null | undefined,
  tbdId?: number
): number | null {
  if (match.stage !== "KNOCKOUT") return predictedAdvancingTeamId ?? null;

  if (predictedHome !== predictedAway) {
    return predictedHome > predictedAway ? match.home_team_id : match.away_team_id;
  }

  const adv = predictedAdvancingTeamId ?? null;
  if (!adv) return null;
  if (tbdId != null && adv === tbdId) return null;
  if (adv === match.home_team_id || adv === match.away_team_id) return adv;
  return adv;
}

export function resolveKnockoutAdvancingWithResolvedTeams(
  predictedHome: number,
  predictedAway: number,
  predictedAdvancingTeamId: number | null | undefined,
  homeId: number,
  awayId: number,
  tbdId: number
): number | null {
  if (predictedHome !== predictedAway) {
    return predictedHome > predictedAway ? homeId : awayId;
  }
  const adv = predictedAdvancingTeamId != null ? Number(predictedAdvancingTeamId) : null;
  if (adv != null && !Number.isNaN(adv) && adv !== tbdId) return adv;
  return null;
}

export { knockoutExternalNum, resolveKnockoutBracketTeams };
