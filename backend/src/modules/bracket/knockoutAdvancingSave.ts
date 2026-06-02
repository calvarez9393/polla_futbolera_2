import { getTbdTeamId, loadPredictionsMap } from "./knockoutAdvancement.js";
import type { KnockoutMatchRow } from "./knockoutBracketLogic.js";
import {
  knockoutExternalNum,
  resolveKnockoutAdvancingWithResolvedTeams,
  resolveKnockoutBracketTeams
} from "./knockoutAdvancingResolve.js";

/** Valida y resuelve quién avanza al guardar predicción (usa equipos efectivos del cuadro). */
export async function resolveKnockoutAdvancingForSave(
  match: {
    id: number;
    external_id?: string;
    stage?: string;
    status?: string;
    home_team_id: number;
    away_team_id: number;
    home_score?: number | null;
    away_score?: number | null;
    winner_team_id?: number | null;
  },
  userId: number,
  predictedHome: number,
  predictedAway: number,
  predictedAdvancingTeamId: number | null | undefined
): Promise<number | null> {
  if (match.stage !== "KNOCKOUT") {
    return predictedAdvancingTeamId ?? null;
  }

  const tbdId = await getTbdTeamId();
  let homeId = match.home_team_id;
  let awayId = match.away_team_id;

  const extNum = match.external_id ? knockoutExternalNum(match.external_id) : null;
  if (extNum != null && match.external_id) {
    const koRow: KnockoutMatchRow = {
      id: match.id,
      external_id: match.external_id,
      status: match.status ?? "NOT_STARTED",
      home_team_id: match.home_team_id,
      away_team_id: match.away_team_id,
      home_score: match.home_score ?? null,
      away_score: match.away_score ?? null,
      winner_team_id: match.winner_team_id ?? null
    };
    const preds = await loadPredictionsMap(userId, [match.id]);
    const resolved = resolveKnockoutBracketTeams([koRow], preds, tbdId).get(extNum);
    if (resolved) {
      if (resolved.homeTeamId !== tbdId) homeId = resolved.homeTeamId;
      if (resolved.awayTeamId !== tbdId) awayId = resolved.awayTeamId;
    }
  }

  return resolveKnockoutAdvancingWithResolvedTeams(
    predictedHome,
    predictedAway,
    predictedAdvancingTeamId,
    homeId,
    awayId,
    tbdId
  );
}
