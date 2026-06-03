import { getActiveTournamentId } from "../settings/service.js";
import {
  getTbdTeamId,
  loadKnockoutRowsForTournament,
  loadPredictionsMap
} from "./knockoutAdvancement.js";
import { resolveKnockoutBracketTeams } from "./knockoutBracketLogic.js";
import { loadOfficialR16SlotsMap } from "./r16Service.js";

/** Cuadro simulado del usuario: dieciseisavos con clasificados reales, resto según predicciones. */
export async function resolveUserKnockoutBracketTeams(
  userId: number,
  tournamentId?: number
): Promise<Map<number, { homeTeamId: number; awayTeamId: number }>> {
  const tid = tournamentId ?? (await getActiveTournamentId());
  if (!tid) return new Map();

  const rows = await loadKnockoutRowsForTournament(tid);
  if (rows.length === 0) return new Map();

  const tbdId = await getTbdTeamId();
  const preds = await loadPredictionsMap(
    userId,
    rows.map((r) => r.id)
  );
  const r16Official = await loadOfficialR16SlotsMap(tid);

  return resolveKnockoutBracketTeams(rows, preds, tbdId, r16Official);
}
