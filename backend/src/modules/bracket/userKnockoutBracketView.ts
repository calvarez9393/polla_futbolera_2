import { pool } from "../../db/pool.js";
import { getActiveTournamentId } from "../settings/service.js";
import {
  getTbdTeamId,
  knockoutExternalNum,
  loadPredictionsMap,
  loadTeamNames
} from "./knockoutAdvancement.js";
import { matchOutcomeFromPrediction } from "./knockoutBracketLogic.js";
import { resolveUserKnockoutBracketTeams } from "./resolveUserKnockoutBracket.js";

export interface UserBracketTeam {
  teamId: number;
  name: string;
  logoUrl: string | null;
}

export interface UserBracketMatch {
  matchId: number;
  externalNum: number;
  roundKey: string;
  roundLabel: string;
  status: string;
  home: UserBracketTeam | null;
  away: UserBracketTeam | null;
  advancingTeamId: number | null;
  advancingTeamName: string | null;
  advancingViaPenalties: boolean;
  predictedHomeScore: number | null;
  predictedAwayScore: number | null;
}

const ROUND_ORDER_SQL = `CASE m.round_key
  WHEN 'R16' THEN 1
  WHEN 'R8' THEN 2
  WHEN 'R4' THEN 3
  WHEN 'SF' THEN 4
  WHEN 'TP3' THEN 5
  WHEN 'F' THEN 6
  ELSE 7
END`;

/**
 * Cuadro eliminatorio SIMULADO de un usuario (lo que él predijo), resuelto EN VIVO ronda por ronda
 * desde sus picks actuales. A diferencia de la vista de scoring, no usa el snapshot guardado por
 * partido: así la ramificación siempre es coherente (el ganador de cuartos aparece en semifinal,
 * etc.), aunque el usuario haya cambiado una ronda anterior después de llenar las siguientes.
 */
export async function buildUserKnockoutBracketView(userId: number): Promise<UserBracketMatch[]> {
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) return [];

  const result = await pool.query(
    `SELECT m.id, m.external_id, m.round_key, m.round_label, m.status,
      p.predicted_home_score, p.predicted_away_score, p.predicted_advancing_team_id
    FROM matches m
    LEFT JOIN predictions p ON p.match_id = m.id AND p.user_id = $2
    WHERE m.tournament_id = $1 AND m.stage = 'KNOCKOUT'
    ORDER BY ${ROUND_ORDER_SQL}, m.starts_at ASC`,
    [tournamentId, userId]
  );
  const rows = result.rows;
  if (rows.length === 0) return [];

  const tbdId = await getTbdTeamId();
  const resolved = await resolveUserKnockoutBracketTeams(userId, tournamentId);
  const preds = await loadPredictionsMap(
    userId,
    rows.map((r) => Number(r.id))
  );

  const ids = new Set<number>();
  for (const v of resolved.values()) {
    ids.add(v.homeTeamId);
    ids.add(v.awayTeamId);
  }
  const names = await loadTeamNames([...ids]);
  const teamOf = (id: number | null): UserBracketTeam | null => {
    if (!id || id === tbdId) return null;
    const t = names.get(id);
    return t ? { teamId: id, name: t.name, logoUrl: t.logoUrl } : null;
  };

  return rows.map((row) => {
    const num = knockoutExternalNum(row.external_id as string) ?? 0;
    const slot = resolved.get(num);
    const homeId = slot?.homeTeamId ?? null;
    const awayId = slot?.awayTeamId ?? null;
    const pred = preds.get(Number(row.id));

    let advancingTeamId: number | null = null;
    let advancingViaPenalties = false;
    if (homeId && awayId && homeId !== tbdId && awayId !== tbdId) {
      advancingTeamId = matchOutcomeFromPrediction(pred, homeId, awayId, tbdId).winnerId;
      const ph = pred?.predicted_home_score ?? null;
      const pa = pred?.predicted_away_score ?? null;
      advancingViaPenalties = Boolean(advancingTeamId && ph != null && pa != null && ph === pa);
    }

    return {
      matchId: Number(row.id),
      externalNum: num,
      roundKey: (row.round_key as string) ?? "",
      roundLabel: (row.round_label as string) ?? "",
      status: (row.status as string) ?? "",
      home: teamOf(homeId),
      away: teamOf(awayId),
      advancingTeamId,
      advancingTeamName: teamOf(advancingTeamId)?.name ?? null,
      advancingViaPenalties,
      predictedHomeScore: pred?.predicted_home_score ?? null,
      predictedAwayScore: pred?.predicted_away_score ?? null
    };
  });
}
