import { pool } from "../../db/pool.js";
import type { FifaQualifiersResult } from "../standings/simulate.js";
import { getActiveTournamentId } from "../settings/service.js";
import { computeOfficialFifaFromResults } from "./fifaFromStandings.js";
import { R16FixtureDef, R16SlotRef, WC2026_R16_FIXTURES } from "./r16Slots.js";
import { groupLetterFromName } from "./groupLetter.js";
import { assignThirdPlacesToR32Slots } from "./thirdPlaceResolver.js";
import { r4NumForR16, r8NumForR16, WC2026_R32_TO_R16 } from "./wc2026R32Fixtures.js";
import { enrichKnockoutAdvancingOnRows, loadPredictionsMap } from "./knockoutAdvancement.js";
import { resolveKnockoutAdvancingTeamId } from "./knockoutAdvancingResolve.js";
import { knockoutExternalNum, type KnockoutMatchRow } from "./knockoutBracketLogic.js";

export interface BracketTeam {
  teamId: number;
  name: string;
  shortName: string | null;
  logoUrl: string | null;
  groupName: string | null;
}

export interface R16BracketMatch {
  matchId: number;
  matchNumber: number;
  externalNum: number;
  label: string;
  homeSlotLabel: string;
  awaySlotLabel: string;
  startsAt: string;
  dateLocal: string;
  city: string;
  octavosMatchNum: number;
  octavosLabel: string;
  cuartosMatchNum: number | null;
  bracketSide: "left" | "right";
  home: BracketTeam | null;
  away: BracketTeam | null;
  isOfficial: boolean;
  advancingTeam?: BracketTeam | null;
  advancingViaPenalties?: boolean;
  nextRoundLabel?: string;
}

export interface BracketTreePair {
  side: "left" | "right";
  r32Nums: [number, number];
  r16Num: number;
  r8Num: number;
}

export interface ThirdPlaceSummary {
  teamId: number;
  name: string;
  groupName: string;
  points: number;
  goalDiff: number;
  goalsFor: number;
  assignedToMatch: number | null;
}

export interface BracketQualifiersSummary {
  bestThirds: ThirdPlaceSummary[];
  allThirdsCount: number;
  directQualifiersCount: number;
  thirdSlotsAssigned: number;
  finishedGroupMatches: number;
  groupsWithFullTable: number;
}

export { computeOfficialFifaFromResults };

interface QualifierPool {
  byGroup: Map<string, { first: number | null; second: number | null; third: number | null }>;
  bestThirds: number[];
  thirdByMatch: Map<number, number>;
  tbdTeamId: number;
}

async function getTbdTeamId(): Promise<number> {
  const row = await pool.query("SELECT id FROM teams WHERE external_id = 'wc2026-tbd' LIMIT 1");
  if (!row.rows[0]) throw new Error("Equipo TBD no encontrado; importa el cuadro eliminatorio");
  return row.rows[0].id as number;
}

function poolFromFifa(fifa: FifaQualifiersResult, tbdTeamId: number): QualifierPool {
  const byGroup = new Map<string, { first: number | null; second: number | null; third: number | null }>();
  for (const g of fifa.groups) {
    byGroup.set(groupLetterFromName(g.groupName), {
      first: g.first,
      second: g.second,
      third: g.third
    });
  }
  return {
    byGroup,
    bestThirds: fifa.bestThirds.map((t) => t.teamId),
    thirdByMatch: assignThirdPlacesToR32Slots(fifa),
    tbdTeamId
  };
}

function resolveSlotTeamId(slot: R16SlotRef, pool: QualifierPool): number | null {
  if (slot.kind === "third_combo" && slot.matchNum) {
    return pool.thirdByMatch.get(slot.matchNum) ?? null;
  }
  const g = pool.byGroup.get(slot.group.toUpperCase());
  if (!g) return null;
  if (slot.kind === "first") return g.first;
  return g.second;
}

export function getBracketTreeMeta(): { pairs: BracketTreePair[] } {
  return {
    pairs: WC2026_R32_TO_R16.map((link) => ({
      side: link.side,
      r32Nums: link.r32Nums,
      r16Num: link.r16Num,
      r8Num: r8NumForR16(link.r16Num) ?? 0
    }))
  };
}

function enrichFixtureMeta(
  fx: R16FixtureDef,
  base: {
    matchId: number;
    homeSlotLabel: string;
    awaySlotLabel: string;
    startsAt: string;
    isOfficial: boolean;
    home: BracketTeam | null;
    away: BracketTeam | null;
  }
): R16BracketMatch {
  return {
    matchId: base.matchId,
    matchNumber: fx.matchNumber,
    externalNum: fx.externalNum,
    label: fx.label,
    homeSlotLabel: base.homeSlotLabel,
    awaySlotLabel: base.awaySlotLabel,
    startsAt: base.startsAt,
    dateLocal: fx.dateLocal,
    city: fx.city,
    octavosMatchNum: fx.octavosMatchNum,
    octavosLabel: `Octavos · Partido ${fx.octavosMatchNum}`,
    cuartosMatchNum: r4NumForR16(fx.octavosMatchNum) ?? null,
    bracketSide: fx.bracketSide,
    home: base.home,
    away: base.away,
    isOfficial: base.isOfficial
  };
}

export async function getUserR16SlotTeamIds(
  userId: number,
  externalNum: number
): Promise<{ homeTeamId: number; awayTeamId: number } | null> {
  const tbdId = await getTbdTeamId();
  const { computeUserQualifiersFromPredictions } = await import("../qualifiers/fromPredictions.js");
  const fifa = await computeUserQualifiersFromPredictions(userId);
  const poolData = poolFromFifa(fifa, tbdId);
  const resolved = resolveR16FromPool(WC2026_R16_FIXTURES, poolData, new Map());
  const fx = WC2026_R16_FIXTURES.find((f) => f.externalNum === externalNum);
  if (!fx) return null;
  const slot = resolved.find((r) => r.matchNumber === fx.matchNumber);
  if (!slot?.homeTeamId || !slot?.awayTeamId) return null;
  if (slot.homeTeamId === tbdId || slot.awayTeamId === tbdId) return null;
  return { homeTeamId: slot.homeTeamId, awayTeamId: slot.awayTeamId };
}

/** Clasificados reales en cada cruce de dieciseisavos (BD o tablas oficiales de grupos). */
export async function loadOfficialR16SlotsMap(
  tournamentId: number
): Promise<Map<number, { homeTeamId: number; awayTeamId: number }>> {
  const tbdId = await getTbdTeamId();
  const map = new Map<number, { homeTeamId: number; awayTeamId: number }>();

  const result = await pool.query(
    `SELECT external_id, home_team_id, away_team_id
    FROM matches
    WHERE tournament_id = $1 AND stage = 'KNOCKOUT' AND round_key = 'R16'`,
    [tournamentId]
  );

  let poolResolved: ReturnType<typeof resolveR16FromPool> | null = null;
  try {
    const fifa = await computeOfficialFifaFromResults();
    poolResolved = resolveR16FromPool(WC2026_R16_FIXTURES, poolFromFifa(fifa, tbdId), new Map());
  } catch {
    poolResolved = null;
  }

  for (const row of result.rows) {
    const num = knockoutExternalNum(row.external_id as string);
    if (num == null) continue;

    const h = Number(row.home_team_id);
    const a = Number(row.away_team_id);
    if (h !== tbdId && a !== tbdId) {
      map.set(num, { homeTeamId: h, awayTeamId: a });
      continue;
    }

    if (poolResolved) {
      const fx = WC2026_R16_FIXTURES.find((f) => f.externalNum === num);
      const slot = poolResolved.find((r) => r.matchNumber === fx?.matchNumber);
      if (slot?.homeTeamId && slot?.awayTeamId) {
        map.set(num, { homeTeamId: slot.homeTeamId, awayTeamId: slot.awayTeamId });
      }
    }
  }

  return map;
}

export function resolveR16FromPool(
  fixtures: R16FixtureDef[],
  pool: QualifierPool,
  _teamById: Map<number, BracketTeam>
): Array<{ matchNumber: number; homeTeamId: number | null; awayTeamId: number | null }> {
  return fixtures.map((fx) => {
    const homeId = resolveSlotTeamId(fx.homeSlot, pool);
    const awayId = resolveSlotTeamId(fx.awaySlot, pool);
    return {
      matchNumber: fx.matchNumber,
      homeTeamId: homeId && homeId !== pool.tbdTeamId ? homeId : null,
      awayTeamId: awayId && awayId !== pool.tbdTeamId ? awayId : null
    };
  });
}

function teamFromMap(teamMap: Map<number, BracketTeam>, teamId: number): BracketTeam | null {
  const t = teamMap.get(teamId);
  return t ? { ...t, teamId } : null;
}

function resolveMatchTeams(
  fx: R16FixtureDef,
  pool: QualifierPool,
  teamMap: Map<number, BracketTeam>
): { home: BracketTeam | null; away: BracketTeam | null; awaySlotLabel: string } {
  const homeId = resolveSlotTeamId(fx.homeSlot, pool);
  const awayId = resolveSlotTeamId(fx.awaySlot, pool);

  const home =
    homeId && homeId !== pool.tbdTeamId ? teamFromMap(teamMap, homeId) : null;

  let away: BracketTeam | null =
    awayId && awayId !== pool.tbdTeamId ? teamFromMap(teamMap, awayId) : null;

  let awaySlotLabel = fx.awaySlotLabel;
  if (fx.awaySlot.kind === "third_combo" && away) {
    awaySlotLabel = `3º Grupo ${away.groupName ?? "?"}`;
  }

  return { home, away, awaySlotLabel };
}

export function buildQualifiersSummary(
  fifa: FifaQualifiersResult & { finishedGroupMatches?: number; groupsWithFullTable?: number },
  thirdByMatch: Map<number, number>,
  teamMap: Map<number, BracketTeam>
): BracketQualifiersSummary {
  const assignmentByTeam = new Map<number, number>();
  for (const [matchNum, teamId] of thirdByMatch) {
    assignmentByTeam.set(teamId, matchNum);
  }

  return {
    bestThirds: fifa.bestThirds.map((t) => ({
      teamId: t.teamId,
      name: teamMap.get(t.teamId)?.name ?? `Equipo ${t.teamId}`,
      groupName: t.groupName,
      points: t.points,
      goalDiff: t.goalDiff,
      goalsFor: t.goalsFor,
      assignedToMatch: assignmentByTeam.get(t.teamId) ?? null
    })),
    allThirdsCount: fifa.allThirdsRanked.length,
    directQualifiersCount: fifa.directQualifiers.length,
    thirdSlotsAssigned: thirdByMatch.size,
    finishedGroupMatches: fifa.finishedGroupMatches ?? 0,
    groupsWithFullTable: fifa.groupsWithFullTable ?? 0
  };
}

async function loadTeamMap(tournamentId: number): Promise<Map<number, BracketTeam>> {
  const teamsResult = await pool.query(
    `SELECT t.id, t.name, t.short_name, t.logo_url, g.name AS group_name
    FROM teams t
    JOIN standings s ON s.team_id = t.id AND s.tournament_id = $1
    JOIN groups g ON g.id = s.group_id`,
    [tournamentId]
  );
  return new Map(
    teamsResult.rows.map((r) => [
      r.id as number,
      {
        teamId: r.id as number,
        name: r.name as string,
        shortName: r.short_name as string | null,
        logoUrl: r.logo_url as string | null,
        groupName: r.group_name as string | null
      }
    ])
  );
}

async function loadR16MatchRows(tournamentId: number) {
  const tbdId = await getTbdTeamId();
  const result = await pool.query(
    `SELECT m.id, m.external_id, m.starts_at, m.round_label,
      m.home_team_id, m.away_team_id,
      ht.name AS home_name, ht.short_name AS home_short, ht.logo_url AS home_logo,
      at.name AS away_name, at.short_name AS away_short, at.logo_url AS away_logo
    FROM matches m
    JOIN teams ht ON ht.id = m.home_team_id
    JOIN teams at ON at.id = m.away_team_id
    WHERE m.tournament_id = $1 AND m.stage = 'KNOCKOUT' AND m.round_key = 'R16'
    ORDER BY m.starts_at ASC, m.id ASC`,
    [tournamentId]
  );
  return { rows: result.rows, tbdId };
}

function externalNumFromId(externalId: string): number {
  const m = externalId.match(/wc2026-ko-(\d+)/);
  return m ? Number(m[1]) : 0;
}

function fixtureForExternalNum(num: number): R16FixtureDef | undefined {
  return WC2026_R16_FIXTURES.find((f) => f.externalNum === num);
}

function rowToBracketMatch(
  row: Record<string, unknown>,
  tbdId: number,
  groupNames: Map<number, string | null>
): R16BracketMatch {
  const extNum = externalNumFromId(row.external_id as string);
  const fx = fixtureForExternalNum(extNum);
  const homeId = row.home_team_id as number;
  const awayId = row.away_team_id as number;
  const homeOfficial = homeId !== tbdId;
  const awayOfficial = awayId !== tbdId;

  if (!fx) {
    return {
      matchId: row.id as number,
      matchNumber: 0,
      externalNum: extNum,
      label: row.round_label as string,
      homeSlotLabel: "",
      awaySlotLabel: "",
      startsAt: (row.starts_at as Date).toISOString(),
      dateLocal: "",
      city: "",
      octavosMatchNum: 0,
      octavosLabel: "",
      cuartosMatchNum: null,
      bracketSide: "left",
      isOfficial: homeOfficial && awayOfficial,
      home: null,
      away: null
    };
  }

  return enrichFixtureMeta(fx, {
    matchId: row.id as number,
    homeSlotLabel: fx.homeSlotLabel,
    awaySlotLabel: fx.awaySlotLabel,
    startsAt: (row.starts_at as Date).toISOString(),
    isOfficial: homeOfficial && awayOfficial,
    home: homeOfficial
      ? {
          teamId: homeId,
          name: row.home_name as string,
          shortName: row.home_short as string | null,
          logoUrl: row.home_logo as string | null,
          groupName: groupNames.get(homeId) ?? null
        }
      : null,
    away: awayOfficial
      ? {
          teamId: awayId,
          name: row.away_name as string,
          shortName: row.away_short as string | null,
          logoUrl: row.away_logo as string | null,
          groupName: groupNames.get(awayId) ?? null
        }
      : null
  });
}

/** Cuadro oficial desde partidos R16 en BD. */
export async function getOfficialR16Bracket(): Promise<{
  matches: R16BracketMatch[];
  hasKnockout: boolean;
  tree: ReturnType<typeof getBracketTreeMeta>;
  qualifiers: BracketQualifiersSummary | null;
}> {
  const tournamentId = await getActiveTournamentId();
  const tree = getBracketTreeMeta();
  if (!tournamentId) return { matches: [], hasKnockout: false, tree, qualifiers: null };

  const { rows, tbdId } = await loadR16MatchRows(tournamentId);
  if (rows.length === 0) return { matches: [], hasKnockout: false, tree, qualifiers: null };

  let qualifiers: BracketQualifiersSummary | null = null;
  try {
    const fifa = await computeOfficialFifaFromResults();
    const poolData = poolFromFifa(fifa, tbdId);
    const teamMap = await loadTeamMap(tournamentId);
    qualifiers = buildQualifiersSummary(fifa, poolData.thirdByMatch, teamMap);
  } catch {
    qualifiers = null;
  }

  const teamMap = await loadTeamMap(tournamentId);
  const groupNames = new Map<number, string | null>();
  for (const [id, t] of teamMap) groupNames.set(id, t.groupName);

  const enrichRows: Array<Record<string, unknown>> = rows.map((row) => ({
    id: row.id,
    external_id: row.external_id,
    stage: "KNOCKOUT",
    round_key: "R16",
    status: row.status,
    home_team_id: row.home_team_id,
    away_team_id: row.away_team_id,
    home_score: row.home_score,
    away_score: row.away_score,
    winner_team_id: row.winner_team_id
  }));
  await enrichKnockoutAdvancingOnRows(null, enrichRows);

  const matches = rows.map((row) => {
    const m = rowToBracketMatch(row, tbdId, groupNames);
    const enriched = enrichRows.find((r) => Number(r.id) === m.matchId);
    if (enriched?.advancingTeamId) {
      const t = teamMap.get(Number(enriched.advancingTeamId));
      if (t) {
        m.advancingTeam = { ...t, teamId: Number(enriched.advancingTeamId) };
        m.advancingViaPenalties = Boolean(enriched.advancingViaPenalties);
        m.nextRoundLabel = (enriched.nextRoundLabel as string) ?? "octavos de final";
      }
    }
    return m;
  });
  matches.sort((a, b) => a.matchNumber - b.matchNumber);

  return { matches, hasKnockout: true, tree, qualifiers };
}

export async function applyR16PairingsToMatches(
  pairings: Array<{ matchId: number; homeTeamId: number; awayTeamId: number }>
): Promise<void> {
  const tbdId = await getTbdTeamId();
  for (const p of pairings) {
    if (p.homeTeamId === tbdId || p.awayTeamId === tbdId) {
      throw new Error("Selecciona equipos reales, no «Por definir»");
    }
    if (p.homeTeamId === p.awayTeamId) {
      throw new Error("Local y visitante no pueden ser el mismo equipo");
    }
    await pool.query(
      `UPDATE matches SET home_team_id = $1, away_team_id = $2, updated_at = NOW()
      WHERE id = $3 AND round_key = 'R16'`,
      [p.homeTeamId, p.awayTeamId, p.matchId]
    );
  }
}

function r16SlotMissingReason(
  fx: R16FixtureDef,
  slot: { homeTeamId: number | null; awayTeamId: number | null } | undefined
): string {
  const reasons: string[] = [];
  if (!slot?.homeTeamId) reasons.push(`falta local (${fx.homeSlotLabel})`);
  if (!slot?.awayTeamId) {
    reasons.push(
      fx.awaySlot.kind === "third_combo"
        ? `falta 3º (${fx.awaySlotLabel}) — ¿8 mejores terceros calculados?`
        : `falta visitante (${fx.awaySlotLabel})`
    );
  }
  return reasons.join("; ");
}

export async function autoFillOfficialR16FromResults(
  options: { onlyTbd?: boolean } = {}
): Promise<{
  updated: number;
  total: number;
  missing: Array<{ matchNum: number; reason: string }>;
  qualifiers: BracketQualifiersSummary;
}> {
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) throw new Error("No hay torneo activo");

  const fifa = await computeOfficialFifaFromResults();
  const tbdId = await getTbdTeamId();
  const poolData = poolFromFifa(fifa, tbdId);
  const teamMap = await loadTeamMap(tournamentId);
  const qualifiers = buildQualifiersSummary(fifa, poolData.thirdByMatch, teamMap);
  const resolved = resolveR16FromPool(WC2026_R16_FIXTURES, poolData, teamMap);

  const { rows } = await loadR16MatchRows(tournamentId);
  // Con onlyTbd solo se llenan cruces aún «Por definir»: los ya fijados (auto o corregidos
  // a mano por el admin) se respetan.
  const targetRows = options.onlyTbd
    ? rows.filter(
        (row) => Number(row.home_team_id) === tbdId || Number(row.away_team_id) === tbdId
      )
    : rows;
  const pairings: Array<{ matchId: number; homeTeamId: number; awayTeamId: number }> = [];
  const missing: Array<{ matchNum: number; reason: string }> = [];

  for (const row of targetRows) {
    const extNum = externalNumFromId(row.external_id as string);
    const fx = fixtureForExternalNum(extNum);
    if (!fx) continue;
    const slot = resolved.find((r) => r.matchNumber === fx.matchNumber);
    if (!slot?.homeTeamId || !slot?.awayTeamId) {
      missing.push({ matchNum: extNum, reason: r16SlotMissingReason(fx, slot) });
      continue;
    }
    pairings.push({
      matchId: row.id as number,
      homeTeamId: slot.homeTeamId,
      awayTeamId: slot.awayTeamId
    });
  }

  if (pairings.length === 0) {
    // Con onlyTbd y todos los cruces ya definidos no hay nada pendiente: no es un error.
    if (options.onlyTbd && targetRows.length === 0) {
      return { updated: 0, total: rows.length, missing, qualifiers };
    }
    throw new Error(
      `No se pudo armar ningún cruce. Partidos de grupo finalizados: ${qualifiers.finishedGroupMatches}. ` +
        `Grupos con tabla completa: ${qualifiers.groupsWithFullTable}/12. ` +
        `Mejores terceros: ${qualifiers.bestThirds.length}/8. ` +
        `Terceros asignados a ranuras: ${qualifiers.thirdSlotsAssigned}/8. ` +
        `Finaliza más partidos de grupos o completa el cuadro manualmente.`
    );
  }

  await applyR16PairingsToMatches(pairings);
  return { updated: pairings.length, total: rows.length, missing, qualifiers };
}

export async function getPredictedR16Bracket(userId: number): Promise<{
  matches: Array<R16BracketMatch & { homeTeamId: number | null; awayTeamId: number | null }>;
  hasKnockout: boolean;
  tree: ReturnType<typeof getBracketTreeMeta>;
  qualifiers: BracketQualifiersSummary;
  predictedMatches: number;
  expectedGroupMatches: number;
}> {
  const { computeUserQualifiersFromPredictions } = await import("../qualifiers/fromPredictions.js");
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) {
    const emptyQualifiers: BracketQualifiersSummary = {
      bestThirds: [],
      allThirdsCount: 0,
      directQualifiersCount: 0,
      thirdSlotsAssigned: 0,
      finishedGroupMatches: 0,
      groupsWithFullTable: 0
    };
    return {
      matches: [],
      hasKnockout: false,
      tree: getBracketTreeMeta(),
      qualifiers: emptyQualifiers,
      predictedMatches: 0,
      expectedGroupMatches: 0
    };
  }

  const fifa = await computeUserQualifiersFromPredictions(userId);
  const tbdId = await getTbdTeamId();
  const poolData = poolFromFifa(fifa, tbdId);
  const teamMap = await loadTeamMap(tournamentId);
  const qualifiers = buildQualifiersSummary(fifa, poolData.thirdByMatch, teamMap);
  const resolved = resolveR16FromPool(WC2026_R16_FIXTURES, poolData, teamMap);

  const official = await getOfficialR16Bracket();

  const r16Db = await pool.query(
    `SELECT id, external_id, status, home_team_id, away_team_id, home_score, away_score, winner_team_id
    FROM matches
    WHERE tournament_id = $1 AND stage = 'KNOCKOUT' AND round_key = 'R16'`,
    [tournamentId]
  );
  const enrichRows = r16Db.rows.map((r) => ({
    ...r,
    stage: "KNOCKOUT",
    round_key: "R16"
  }));
  await enrichKnockoutAdvancingOnRows(userId, enrichRows);
  const preds = await loadPredictionsMap(
    userId,
    r16Db.rows.map((r) => Number(r.id))
  );

  const matches = WC2026_R16_FIXTURES.map((fx) => {
    const slot = resolved.find((r) => r.matchNumber === fx.matchNumber);
    const officialMatch = official.matches.find((m) => m.externalNum === fx.externalNum);
    const { home, away, awaySlotLabel } = resolveMatchTeams(fx, poolData, teamMap);
    const dbRow = r16Db.rows.find(
      (r) => knockoutExternalNum(r.external_id as string) === fx.externalNum
    );
    const enriched = enrichRows.find(
      (r) => knockoutExternalNum(r.external_id as string) === fx.externalNum
    );

    let advancingTeam: BracketTeam | null = null;
    let advancingViaPenalties = false;
    let nextRoundLabel = "octavos de final";

    if (enriched?.advancingTeamId) {
      const t = teamMap.get(Number(enriched.advancingTeamId));
      if (t) advancingTeam = { ...t, teamId: Number(enriched.advancingTeamId) };
      advancingViaPenalties = Boolean(enriched.advancingViaPenalties);
      nextRoundLabel = (enriched.nextRoundLabel as string) ?? nextRoundLabel;
    } else if (dbRow && home && away) {
      const ko: KnockoutMatchRow = {
        id: Number(dbRow.id),
        external_id: dbRow.external_id as string,
        status: dbRow.status as string,
        home_team_id: Number(dbRow.home_team_id),
        away_team_id: Number(dbRow.away_team_id),
        home_score: dbRow.home_score as number | null,
        away_score: dbRow.away_score as number | null,
        winner_team_id: dbRow.winner_team_id as number | null
      };
      const advId = resolveKnockoutAdvancingTeamId(
        ko,
        preds.get(ko.id),
        slot?.homeTeamId ?? ko.home_team_id,
        slot?.awayTeamId ?? ko.away_team_id,
        tbdId
      );
      if (advId) {
        const t = teamMap.get(advId);
        if (t) advancingTeam = { ...t, teamId: advId };
        const ph = preds.get(ko.id)?.predicted_home_score;
        const pa = preds.get(ko.id)?.predicted_away_score;
        advancingViaPenalties =
          ph != null && pa != null && ph === pa && ko.status !== "FINISHED";
      }
    }

    return {
      ...enrichFixtureMeta(fx, {
        matchId: officialMatch?.matchId ?? 0,
        homeSlotLabel: fx.homeSlotLabel,
        awaySlotLabel,
        startsAt: officialMatch?.startsAt ?? `${fx.dateLocal}T12:00:00.000Z`,
        isOfficial: false,
        home,
        away
      }),
      homeTeamId: slot?.homeTeamId ?? null,
      awayTeamId: slot?.awayTeamId ?? null,
      advancingTeam,
      advancingViaPenalties,
      nextRoundLabel
    };
  });

  return {
    matches,
    hasKnockout: official.hasKnockout,
    tree: official.tree,
    qualifiers,
    predictedMatches: fifa.predictedMatches,
    expectedGroupMatches: fifa.expectedGroupMatches
  };
}

export async function listQualifiedTeamsForR16(): Promise<BracketTeam[]> {
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) return [];
  const teamMap = await loadTeamMap(tournamentId);
  return [...teamMap.values()].sort((a, b) =>
    (a.groupName ?? "").localeCompare(b.groupName ?? "") || a.name.localeCompare(b.name, "es")
  );
}
