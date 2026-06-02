import { knockoutExternalNum, matchOutcome, resolveKnockoutBracketTeams } from "./knockoutBracketLogic.js";
export function resolveKnockoutAdvancingTeamId(match, prediction, homeTeamId, awayTeamId, tbdId) {
    return matchOutcome(match, prediction, homeTeamId, awayTeamId, tbdId).winnerId;
}
export function resolvePredictionAdvancingTeamId(match, predictedHome, predictedAway, predictedAdvancingTeamId, tbdId) {
    if (match.stage !== "KNOCKOUT")
        return predictedAdvancingTeamId ?? null;
    if (predictedHome !== predictedAway) {
        return predictedHome > predictedAway ? match.home_team_id : match.away_team_id;
    }
    const adv = predictedAdvancingTeamId ?? null;
    if (!adv)
        return null;
    if (tbdId != null && adv === tbdId)
        return null;
    if (adv === match.home_team_id || adv === match.away_team_id)
        return adv;
    return adv;
}
export function resolveKnockoutAdvancingWithResolvedTeams(predictedHome, predictedAway, predictedAdvancingTeamId, homeId, awayId, tbdId) {
    if (predictedHome !== predictedAway) {
        return predictedHome > predictedAway ? homeId : awayId;
    }
    const adv = predictedAdvancingTeamId ?? null;
    if (adv && adv !== tbdId)
        return adv;
    return null;
}
export { knockoutExternalNum, resolveKnockoutBracketTeams };
