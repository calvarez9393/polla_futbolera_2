import { pool } from "../../db/pool.js";
import { getActiveTournamentId } from "../settings/service.js";
import { getUserR16SlotTeamIds } from "./r16Service.js";
import {
  getTbdTeamId,
  loadKnockoutRowsForTournament,
  loadPredictionsMap
} from "./knockoutAdvancement.js";
import { knockoutExternalNum, resolveKnockoutBracketTeams } from "./knockoutBracketLogic.js";

export interface SlotTeams {
  homeTeamId: number;
  awayTeamId: number;
}

export async function resolveUserSlotTeamsForMatch(
  userId: number,
  match: {
    id: number;
    external_id?: string | null;
    stage?: string | null;
    round_key?: string | null;
    home_team_id: number;
    away_team_id: number;
    tournament_id?: number;
  }
): Promise<SlotTeams | null> {
  if (match.stage !== "KNOCKOUT") return null;

  const tbdId = await getTbdTeamId();
  const extNum = match.external_id ? knockoutExternalNum(match.external_id) : null;
  if (extNum == null) return null;

  if (match.round_key === "R16") {
    return getUserR16SlotTeamIds(userId, extNum);
  }

  const tournamentId =
    match.tournament_id ?? (await getActiveTournamentId());
  if (!tournamentId) return null;

  const rows = await loadKnockoutRowsForTournament(tournamentId);
  const preds = await loadPredictionsMap(
    userId,
    rows.map((r) => r.id)
  );
  const slot = resolveKnockoutBracketTeams(rows, preds, tbdId).get(extNum);
  if (!slot) return null;
  if (slot.homeTeamId === tbdId || slot.awayTeamId === tbdId) return null;

  return { homeTeamId: slot.homeTeamId, awayTeamId: slot.awayTeamId };
}

/** Equipos guardados al predecir; si faltan, se resuelven del cuadro actual del usuario. */
export async function getUserBracketTeamsForScoring(
  userId: number,
  match: {
    id: number;
    external_id?: string | null;
    stage?: string | null;
    round_key?: string | null;
    home_team_id: number;
    away_team_id: number;
    tournament_id?: number;
  },
  prediction?: {
    bracket_home_team_id?: number | null;
    bracket_away_team_id?: number | null;
  } | null
): Promise<SlotTeams | null> {
  const bh = prediction?.bracket_home_team_id;
  const ba = prediction?.bracket_away_team_id;
  const tbdId = await getTbdTeamId();
  if (bh != null && ba != null && bh !== tbdId && ba !== tbdId) {
    return { homeTeamId: Number(bh), awayTeamId: Number(ba) };
  }
  return resolveUserSlotTeamsForMatch(userId, match);
}

export async function loadUserBracketSnapshotsForMatches(
  userId: number,
  matchIds: number[]
): Promise<Map<number, SlotTeams>> {
  const map = new Map<number, SlotTeams>();
  if (matchIds.length === 0) return map;

  const result = await pool.query(
    `SELECT match_id, bracket_home_team_id, bracket_away_team_id
    FROM predictions
    WHERE user_id = $1 AND match_id = ANY($2::bigint[])`,
    [userId, matchIds]
  );
  const tbdId = await getTbdTeamId();
  for (const row of result.rows) {
    const h = row.bracket_home_team_id;
    const a = row.bracket_away_team_id;
    if (h == null || a == null || h === tbdId || a === tbdId) continue;
    map.set(Number(row.match_id), { homeTeamId: Number(h), awayTeamId: Number(a) });
  }
  return map;
}
