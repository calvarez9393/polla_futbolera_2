import { getTbdTeamId } from "./knockoutAdvancement.js";
import { resolveKnockoutAdvancingWithResolvedTeams } from "./knockoutAdvancingResolve.js";
import { resolveUserSlotTeamsForMatch } from "./resolveUserSlotTeams.js";

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

  const slot = await resolveUserSlotTeamsForMatch(userId, match);
  if (slot) {
    homeId = slot.homeTeamId;
    awayId = slot.awayTeamId;
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
