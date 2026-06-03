import { pool } from "../../db/pool.js";
import { matchFromClause, matchSelectFields } from "../matches/query.js";
import {
  feedsReferencing,
  knockoutExternalNum,
  KNOCKOUT_MATCH_ORDER,
  matchOutcome,
  matchOutcomeFromPrediction,
  matchOutcomeOfficial,
  resolveKnockoutBracketTeams,
  type KnockoutMatchRow,
  type UserPredictionRow
} from "./knockoutBracketLogic.js";
export type {
  FeedType,
  KnockoutMatchRow,
  SlotFeed,
  UserPredictionRow
} from "./knockoutBracketLogic.js";
export {
  KNOCKOUT_MATCH_ORDER,
  KNOCKOUT_SLOT_FEEDS,
  knockoutExternalNum,
  matchOutcome,
  matchOutcomeFromPrediction,
  matchOutcomeOfficial,
  parseSlotFeed,
  resolveKnockoutBracketTeams
} from "./knockoutBracketLogic.js";

export async function getTbdTeamId(): Promise<number> {
  const row = await pool.query("SELECT id FROM teams WHERE external_id = 'wc2026-tbd' LIMIT 1");
  if (!row.rows[0]) throw new Error("Equipo TBD no encontrado; importa el cuadro eliminatorio");
  return row.rows[0].id as number;
}

export async function propagateOfficialKnockoutAdvancement(matchId: number): Promise<number> {
  const row = await pool.query(
    `SELECT id, external_id, tournament_id, stage, status,
      home_team_id, away_team_id, home_score, away_score, winner_team_id
    FROM matches WHERE id = $1`,
    [matchId]
  );
  const match = row.rows[0] as KnockoutMatchRow & { tournament_id: number; stage: string } | undefined;
  if (!match || match.stage !== "KNOCKOUT" || match.status !== "FINISHED") return 0;

  const feederNum = knockoutExternalNum(match.external_id);
  if (feederNum == null) return 0;

  const tbdId = await getTbdTeamId();
  const { winnerId, loserId } = matchOutcomeOfficial(
    match,
    match.home_team_id,
    match.away_team_id,
    tbdId
  );
  if (!winnerId) return 0;

  if (!match.winner_team_id || match.winner_team_id === tbdId) {
    await pool.query(`UPDATE matches SET winner_team_id = $1, updated_at = NOW() WHERE id = $2`, [
      winnerId,
      matchId
    ]);
  }

  let updated = 0;
  for (const ref of feedsReferencing(feederNum)) {
    const teamId = ref.feed.type === "winner" ? winnerId : loserId;
    if (!teamId || teamId === tbdId) continue;

    const col = ref.side === "home" ? "home_team_id" : "away_team_id";
    const result = await pool.query(
      `UPDATE matches SET ${col} = $1, updated_at = NOW()
      WHERE tournament_id = $2 AND external_id = $3
      RETURNING id`,
      [teamId, match.tournament_id, `wc2026-ko-${ref.targetNum}`]
    );
    updated += result.rowCount ?? 0;
  }

  return updated;
}

export async function loadKnockoutRowsForTournament(tournamentId: number): Promise<KnockoutMatchRow[]> {
  const result = await pool.query(
    `SELECT id, external_id, status, home_team_id, away_team_id, home_score, away_score, winner_team_id
    FROM matches
    WHERE tournament_id = $1 AND stage = 'KNOCKOUT'
    ORDER BY starts_at ASC`,
    [tournamentId]
  );
  return result.rows.map((row) => toKnockoutMatchRow(row as Record<string, unknown>));
}

export async function loadPredictionsMap(
  userId: number,
  matchIds: number[]
): Promise<Map<number, UserPredictionRow>> {
  if (matchIds.length === 0) return new Map();
  const result = await pool.query(
    `SELECT match_id, predicted_home_score, predicted_away_score, predicted_advancing_team_id
    FROM predictions WHERE user_id = $1 AND match_id = ANY($2::bigint[])`,
    [userId, matchIds]
  );
  const map = new Map<number, UserPredictionRow>();
  for (const row of result.rows) {
    map.set(Number(row.match_id), {
      predicted_home_score:
        row.predicted_home_score != null ? Number(row.predicted_home_score) : null,
      predicted_away_score:
        row.predicted_away_score != null ? Number(row.predicted_away_score) : null,
      predicted_advancing_team_id:
        row.predicted_advancing_team_id != null ? Number(row.predicted_advancing_team_id) : null
    });
  }
  return map;
}

function toKnockoutMatchRow(r: Record<string, unknown>): KnockoutMatchRow {
  return {
    id: Number(r.id),
    external_id: r.external_id as string,
    status: r.status as string,
    home_team_id: Number(r.home_team_id),
    away_team_id: Number(r.away_team_id),
    home_score: r.home_score as number | null,
    away_score: r.away_score as number | null,
    winner_team_id: r.winner_team_id != null ? Number(r.winner_team_id) : null
  };
}

async function loadKnockoutDisplayRows(tournamentId: number): Promise<Array<Record<string, unknown>>> {
  const result = await pool.query(
    `SELECT ${matchSelectFields}
    ${matchFromClause}
    WHERE m.tournament_id = $1 AND m.stage = 'KNOCKOUT'
    ORDER BY m.starts_at ASC`,
    [tournamentId]
  );
  return result.rows as Array<Record<string, unknown>>;
}

export async function applyResolvedTeamsToMatchRows(
  userId: number,
  rows: Array<Record<string, unknown>>
): Promise<void> {
  const displayKoRows = rows.filter((r) => r.stage === "KNOCKOUT");
  if (displayKoRows.length === 0) return;

  const { getActiveTournamentId } = await import("../settings/service.js");
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) return;

  const allRows = await loadKnockoutDisplayRows(tournamentId);
  if (allRows.length === 0) return;

  const tbdId = await getTbdTeamId();
  const knockRows = allRows.map(toKnockoutMatchRow);
  const matchIds = knockRows.map((r) => r.id);
  const { resolveUserKnockoutBracketTeams } = await import("./resolveUserKnockoutBracket.js");
  const resolved = await resolveUserKnockoutBracketTeams(userId, tournamentId);
  const { loadUserBracketSnapshotsForMatches } = await import("./resolveUserSlotTeams.js");
  const snapshots = await loadUserBracketSnapshotsForMatches(userId, matchIds);

  const teamIds: number[] = [];
  for (const row of displayKoRows) {
    row.official_home_team_id = row.home_team_id;
    row.official_away_team_id = row.away_team_id;
    row.official_home_team_name = row.home_team_name;
    row.official_away_team_name = row.away_team_name;
    row.official_home_team_logo_url = row.home_team_logo_url;
    row.official_away_team_logo_url = row.away_team_logo_url;

    const matchId = Number(row.id);
    const snap = snapshots.get(matchId);
    const num = knockoutExternalNum(row.external_id as string);
    const slot = num != null ? resolved.get(num) : undefined;
    const isR16 = row.round_key === "R16";
    const homeTeamId = isR16 ? slot?.homeTeamId : (snap?.homeTeamId ?? slot?.homeTeamId);
    const awayTeamId = isR16 ? slot?.awayTeamId : (snap?.awayTeamId ?? slot?.awayTeamId);
    if (homeTeamId == null || awayTeamId == null) continue;
    row.home_team_id = homeTeamId;
    row.away_team_id = awayTeamId;
    teamIds.push(homeTeamId, awayTeamId);
  }

  const names = await loadTeamNames(teamIds);
  for (const row of displayKoRows) {
    const homeId = Number(row.home_team_id);
    const awayId = Number(row.away_team_id);
    const h = names.get(homeId);
    const a = names.get(awayId);
    if (h) {
      row.home_team_name = h.name;
      row.home_team_logo_url = h.logoUrl;
    }
    if (a) {
      row.away_team_name = a.name;
      row.away_team_logo_url = a.logoUrl;
    }
  }
}

export async function syncAllOfficialKnockoutAdvancement(tournamentId: number): Promise<number> {
  const rows = await loadKnockoutRowsForTournament(tournamentId);
  let total = 0;
  for (const num of KNOCKOUT_MATCH_ORDER) {
    const row = rows.find((r) => knockoutExternalNum(r.external_id) === num);
    if (row?.status === "FINISHED") {
      total += await propagateOfficialKnockoutAdvancement(row.id);
    }
  }
  return total;
}

function nextRoundKeyLabel(roundKey: string | null | undefined): string {
  switch (roundKey?.toUpperCase()) {
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

/** Quién pasa de ronda (oficial o simulación del usuario) para mostrar en UI. */
export async function enrichKnockoutAdvancingOnRows(
  userId: number | null,
  rows: Array<Record<string, unknown>>
): Promise<void> {
  const koRows = rows.filter((r) => r.stage === "KNOCKOUT");
  if (koRows.length === 0) return;

  const tbdId = await getTbdTeamId();
  const knockRows: KnockoutMatchRow[] = koRows.map((r) => ({
    id: Number(r.id),
    external_id: r.external_id as string,
    status: r.status as string,
    home_team_id: Number(r.home_team_id),
    away_team_id: Number(r.away_team_id),
    home_score: r.home_score as number | null,
    away_score: r.away_score as number | null,
    winner_team_id: r.winner_team_id != null ? Number(r.winner_team_id) : null
  }));

  const preds =
    userId != null
      ? await loadPredictionsMap(
          userId,
          knockRows.map((r) => r.id)
        )
      : new Map<number, UserPredictionRow>();

  const resolved =
    userId != null
      ? await (await import("./resolveUserKnockoutBracket.js")).resolveUserKnockoutBracketTeams(userId)
      : new Map<number, { homeTeamId: number; awayTeamId: number }>();

  const snapshots =
    userId != null
      ? await (
          await import("./resolveUserSlotTeams.js")
        ).loadUserBracketSnapshotsForMatches(
          userId,
          knockRows.map((r) => r.id)
        )
      : new Map<number, { homeTeamId: number; awayTeamId: number }>();

  const teamIds: number[] = [];
  for (let i = 0; i < koRows.length; i++) {
    const row = koRows[i];
    const ko = knockRows[i];
    const pred = preds.get(ko.id);
    const num = knockoutExternalNum(ko.external_id);
    const slot = num != null ? resolved.get(num) : undefined;
    const snap = snapshots.get(ko.id);
    const homeId = snap?.homeTeamId ?? slot?.homeTeamId ?? ko.home_team_id;
    const awayId = snap?.awayTeamId ?? slot?.awayTeamId ?? ko.away_team_id;

    const officialHome = Number(row.official_home_team_id ?? ko.home_team_id);
    const officialAway = Number(row.official_away_team_id ?? ko.away_team_id);

    const predAdvId =
      userId != null && pred != null
        ? matchOutcomeFromPrediction(pred, homeId, awayId, tbdId).winnerId
        : null;

    let officialAdvId: number | null = null;
    if (ko.status === "FINISHED") {
      officialAdvId = matchOutcomeOfficial(ko, officialHome, officialAway, tbdId).winnerId;
    }

    const predHome = pred?.predicted_home_score ?? null;
    const predAway = pred?.predicted_away_score ?? null;
    const predIsDraw = predHome != null && predAway != null && predHome === predAway;
    const officialIsDraw =
      ko.status === "FINISHED" &&
      ko.home_score != null &&
      ko.away_score != null &&
      ko.home_score === ko.away_score;

    row.advancingTeamId = predAdvId;
    row.advancingViaPenalties = Boolean(predAdvId && predIsDraw);
    row.officialAdvancingTeamId = officialAdvId;
    row.officialAdvancingViaPenalties = Boolean(officialAdvId && officialIsDraw);
    row.nextRoundLabel = nextRoundKeyLabel(row.round_key as string | undefined);
    if (predAdvId) teamIds.push(predAdvId);
    if (officialAdvId) teamIds.push(officialAdvId);
  }

  const names = await loadTeamNames(teamIds);
  for (const row of koRows) {
    const predId = row.advancingTeamId as number | undefined;
    if (predId) {
      const t = names.get(predId);
      if (t) {
        row.advancingTeamName = t.name;
        row.advancingTeamLogoUrl = t.logoUrl;
      }
    }
    const officialId = row.officialAdvancingTeamId as number | undefined;
    if (officialId) {
      const t = names.get(officialId);
      if (t) {
        row.officialAdvancingTeamName = t.name;
        row.officialAdvancingTeamLogoUrl = t.logoUrl;
      }
    }
  }
}

export async function loadTeamNames(
  teamIds: number[]
): Promise<Map<number, { name: string; logoUrl: string | null }>> {
  const unique = [...new Set(teamIds.filter((id) => id > 0))];
  if (unique.length === 0) return new Map();
  const result = await pool.query(`SELECT id, name, logo_url FROM teams WHERE id = ANY($1::bigint[])`, [
    unique
  ]);
  return new Map(
    result.rows.map((r) => [
      Number(r.id),
      { name: r.name as string, logoUrl: r.logo_url as string | null }
    ])
  );
}
