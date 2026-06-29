import { pool } from "../../db/pool.js";
import { getActiveTournamentId } from "../settings/service.js";
import { getTbdTeamId, knockoutExternalNum, loadTeamNames } from "./knockoutAdvancement.js";
import { resolveUserKnockoutBracketTeams } from "./resolveUserKnockoutBracket.js";

export interface SnapshotResyncChange {
  userId: number;
  userName: string;
  num: number;
  roundLabel: string;
  fromHome: string | null;
  toHome: string | null;
  fromAway: string | null;
  toAway: string | null;
}

export interface SnapshotResyncReport {
  applied: boolean;
  usersAffected: number;
  predictionsUpdated: number;
  matchesRescored: number;
  changes: SnapshotResyncChange[];
}

interface PredRow {
  userId: number;
  userName: string;
  matchId: number;
  num: number;
  roundLabel: string;
  finished: boolean;
  oldHome: number | null;
  oldAway: number | null;
}

/**
 * Resincroniza el cruce guardado (snapshot `bracket_home/away_team_id`) de cada predicción de
 * octavos en adelante con el cuadro EN VIVO del usuario. Corrige el caso en que alguien llenó una
 * ronda y luego cambió una anterior: el snapshot quedaba viejo y el puntaje se calculaba contra un
 * cruce que ya no se desprende de sus picks. Tras actualizar, vuelve a puntuar los partidos
 * afectados. Solo toca octavos+ (en dieciseisavos el puntaje usa el cruce oficial, no el snapshot).
 */
export async function resyncUserBracketSnapshots(
  options: { apply?: boolean; userId?: number } = {}
): Promise<SnapshotResyncReport> {
  const apply = options.apply ?? false;
  const empty: SnapshotResyncReport = {
    applied: apply,
    usersAffected: 0,
    predictionsUpdated: 0,
    matchesRescored: 0,
    changes: []
  };

  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) return empty;
  const tbdId = await getTbdTeamId();

  const params: unknown[] = [tournamentId];
  let userFilter = "";
  if (options.userId != null) {
    params.push(options.userId);
    userFilter = ` AND p.user_id = $${params.length}`;
  }

  const predsRes = await pool.query(
    `SELECT p.user_id, p.match_id, m.external_id, m.round_label, m.status,
      p.bracket_home_team_id, p.bracket_away_team_id,
      COALESCE(u.display_name, u.email) AS user_name
    FROM predictions p
    JOIN matches m ON m.id = p.match_id
    JOIN users u ON u.id = p.user_id
    WHERE m.tournament_id = $1 AND m.stage = 'KNOCKOUT' AND m.round_key <> 'R16'${userFilter}`,
    params
  );
  if (predsRes.rows.length === 0) return empty;

  const byUser = new Map<number, PredRow[]>();
  for (const r of predsRes.rows) {
    const userId = Number(r.user_id);
    const num = knockoutExternalNum(r.external_id as string);
    if (num == null) continue;
    if (!byUser.has(userId)) byUser.set(userId, []);
    byUser.get(userId)!.push({
      userId,
      userName: r.user_name as string,
      matchId: Number(r.match_id),
      num,
      roundLabel: (r.round_label as string) ?? `Partido ${num}`,
      finished: r.status === "FINISHED",
      oldHome: r.bracket_home_team_id != null ? Number(r.bracket_home_team_id) : null,
      oldAway: r.bracket_away_team_id != null ? Number(r.bracket_away_team_id) : null
    });
  }

  interface RawChange extends PredRow {
    newHome: number;
    newAway: number;
  }
  const raw: RawChange[] = [];
  // Solo los partidos YA finalizados necesitan repuntuar: si la corrección se hace antes de
  // finalizarlos no hay puntos que recalcular (y calculateMatchScores ignora los no finalizados).
  const finishedMatchIds = new Set<number>();
  const affectedUsers = new Set<number>();

  for (const [userId, rows] of byUser) {
    const resolved = await resolveUserKnockoutBracketTeams(userId, tournamentId);
    for (const pr of rows) {
      const slot = resolved.get(pr.num);
      if (!slot) continue;
      if (slot.homeTeamId === tbdId || slot.awayTeamId === tbdId) continue; // no pisar con «Por definir»
      if (pr.oldHome === slot.homeTeamId && pr.oldAway === slot.awayTeamId) continue;

      raw.push({ ...pr, newHome: slot.homeTeamId, newAway: slot.awayTeamId });
      if (pr.finished) finishedMatchIds.add(pr.matchId);
      affectedUsers.add(userId);

      if (apply) {
        await pool.query(
          `UPDATE predictions SET bracket_home_team_id = $1, bracket_away_team_id = $2, updated_at = NOW()
          WHERE user_id = $3 AND match_id = $4`,
          [slot.homeTeamId, slot.awayTeamId, userId, pr.matchId]
        );
      }
    }
  }

  // Nombres para el reporte.
  const ids = new Set<number>();
  for (const c of raw) {
    if (c.oldHome) ids.add(c.oldHome);
    if (c.oldAway) ids.add(c.oldAway);
    ids.add(c.newHome);
    ids.add(c.newAway);
  }
  const names = await loadTeamNames([...ids]);
  const nameOf = (id: number | null): string | null => {
    if (id == null) return null;
    if (id === tbdId) return "Por definir";
    return names.get(id)?.name ?? `Equipo ${id}`;
  };

  const changes: SnapshotResyncChange[] = raw.map((c) => ({
    userId: c.userId,
    userName: c.userName,
    num: c.num,
    roundLabel: c.roundLabel,
    fromHome: nameOf(c.oldHome),
    toHome: nameOf(c.newHome),
    fromAway: nameOf(c.oldAway),
    toAway: nameOf(c.newAway)
  }));

  if (apply && finishedMatchIds.size > 0) {
    const { calculateMatchScores } = await import("../scoring/service.js");
    for (const matchId of finishedMatchIds) {
      await calculateMatchScores(matchId);
    }
  }

  return {
    applied: apply,
    usersAffected: affectedUsers.size,
    predictionsUpdated: raw.length,
    matchesRescored: apply ? finishedMatchIds.size : 0,
    changes
  };
}
