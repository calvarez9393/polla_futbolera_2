import { getActiveTournamentId } from "../settings/service.js";
import { getTbdTeamId } from "./knockoutAdvancement.js";
import { knockoutExternalNum } from "./knockoutBracketLogic.js";
import { resolveUserKnockoutBracketTeams } from "./resolveUserKnockoutBracket.js";

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

  const extNum = match.external_id ? knockoutExternalNum(match.external_id) : null;
  if (extNum == null) return null;

  const tid = match.tournament_id ?? (await getActiveTournamentId());
  if (!tid) return null;

  const resolved = await resolveUserKnockoutBracketTeams(userId, tid);
  const slot = resolved.get(extNum);
  if (!slot) return null;

  const tbdId = await getTbdTeamId();
  if (slot.homeTeamId === tbdId || slot.awayTeamId === tbdId) return null;

  return { homeTeamId: slot.homeTeamId, awayTeamId: slot.awayTeamId };
}

/**
 * Cruce contra el que se puntúa cada predicción eliminatoria:
 * - R16 parte de los clasificados reales (todos predicen sobre el cruce oficial).
 * - De octavos en adelante vale el cruce que el usuario vio al predecir (snapshot);
 *   solo si falta se recalcula desde su cuadro.
 */
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
  if (match.stage === "KNOCKOUT" && match.round_key === "R16") {
    return resolveUserSlotTeamsForMatch(userId, match);
  }

  const bh = prediction?.bracket_home_team_id;
  const ba = prediction?.bracket_away_team_id;
  const tbdId = await getTbdTeamId();
  if (bh != null && ba != null && Number(bh) !== tbdId && Number(ba) !== tbdId) {
    return { homeTeamId: Number(bh), awayTeamId: Number(ba) };
  }
  return resolveUserSlotTeamsForMatch(userId, match);
}

export async function loadUserBracketSnapshotsForMatches(
  userId: number,
  matchIds: number[]
): Promise<Map<number, SlotTeams>> {
  const { pool } = await import("../../db/pool.js");
  const map = new Map<number, SlotTeams>();
  if (matchIds.length === 0) return map;

  const result = await pool.query(
    `SELECT p.match_id, p.bracket_home_team_id, p.bracket_away_team_id, m.round_key
    FROM predictions p
    JOIN matches m ON m.id = p.match_id
    WHERE p.user_id = $1 AND p.match_id = ANY($2::bigint[])`,
    [userId, matchIds]
  );
  const tbdId = await getTbdTeamId();
  for (const row of result.rows) {
    if (row.round_key === "R16") continue;
    const h = row.bracket_home_team_id;
    const a = row.bracket_away_team_id;
    if (h == null || a == null || h === tbdId || a === tbdId) continue;
    map.set(Number(row.match_id), { homeTeamId: Number(h), awayTeamId: Number(a) });
  }
  return map;
}

export interface PredictedMatchupDto {
  homeTeamId: number;
  homeTeamName: string;
  homeTeamLogoUrl: string | null;
  awayTeamId: number;
  awayTeamName: string;
  awayTeamLogoUrl: string | null;
}

/** Cruce guardado al momento de predecir (eliminatorias). */
export function predictedMatchupFromRow(row: {
  stage?: string | null;
  predicted_home_score?: number | null;
  bracket_home_team_id?: number | string | null;
  bracket_away_team_id?: number | string | null;
  bracket_home_team_name?: string | null;
  bracket_away_team_name?: string | null;
  bracket_home_team_logo_url?: string | null;
  bracket_away_team_logo_url?: string | null;
  home_team_id?: number | string;
  away_team_id?: number | string;
  home_team_name?: string;
  away_team_name?: string;
  home_team_logo_url?: string | null;
  away_team_logo_url?: string | null;
}): PredictedMatchupDto | null {
  if (row.stage !== "KNOCKOUT" || row.predicted_home_score == null) return null;

  const bracketHomeId =
    row.bracket_home_team_id != null ? Number(row.bracket_home_team_id) : null;
  const bracketAwayId =
    row.bracket_away_team_id != null ? Number(row.bracket_away_team_id) : null;

  if (
    bracketHomeId != null &&
    bracketAwayId != null &&
    row.bracket_home_team_name &&
    row.bracket_away_team_name
  ) {
    return {
      homeTeamId: bracketHomeId,
      homeTeamName: row.bracket_home_team_name,
      homeTeamLogoUrl: row.bracket_home_team_logo_url ?? null,
      awayTeamId: bracketAwayId,
      awayTeamName: row.bracket_away_team_name,
      awayTeamLogoUrl: row.bracket_away_team_logo_url ?? null
    };
  }

  if (row.home_team_name && row.away_team_name) {
    return {
      homeTeamId: Number(row.home_team_id),
      homeTeamName: String(row.home_team_name),
      homeTeamLogoUrl: row.home_team_logo_url ?? null,
      awayTeamId: Number(row.away_team_id),
      awayTeamName: String(row.away_team_name),
      awayTeamLogoUrl: row.away_team_logo_url ?? null
    };
  }

  return null;
}

/** Cruce oficial del calendario (equipos reales del partido en BD). */
export function officialMatchupFromRow(row: {
  official_home_team_id?: number | string | null;
  official_away_team_id?: number | string | null;
  official_home_team_name?: string | null;
  official_away_team_name?: string | null;
  official_home_team_logo_url?: string | null;
  official_away_team_logo_url?: string | null;
  home_team_id?: number | string;
  away_team_id?: number | string;
  home_team_name?: string;
  away_team_name?: string;
  home_team_logo_url?: string | null;
  away_team_logo_url?: string | null;
}): PredictedMatchupDto | null {
  if (row.official_home_team_name && row.official_away_team_name) {
    return {
      homeTeamId: Number(row.official_home_team_id),
      homeTeamName: row.official_home_team_name,
      homeTeamLogoUrl: row.official_home_team_logo_url ?? null,
      awayTeamId: Number(row.official_away_team_id),
      awayTeamName: row.official_away_team_name,
      awayTeamLogoUrl: row.official_away_team_logo_url ?? null
    };
  }

  if (row.home_team_name && row.away_team_name) {
    return {
      homeTeamId: Number(row.home_team_id),
      homeTeamName: String(row.home_team_name),
      homeTeamLogoUrl: row.home_team_logo_url ?? null,
      awayTeamId: Number(row.away_team_id),
      awayTeamName: String(row.away_team_name),
      awayTeamLogoUrl: row.away_team_logo_url ?? null
    };
  }

  return null;
}

export const predictionBracketSelectFields = `
  p.bracket_home_team_id,
  p.bracket_away_team_id,
  bht.name AS bracket_home_team_name,
  bht.logo_url AS bracket_home_team_logo_url,
  bat.name AS bracket_away_team_name,
  bat.logo_url AS bracket_away_team_logo_url
`;

export const predictionBracketJoinClause = `
  LEFT JOIN teams bht ON bht.id = p.bracket_home_team_id
  LEFT JOIN teams bat ON bat.id = p.bracket_away_team_id
`;
