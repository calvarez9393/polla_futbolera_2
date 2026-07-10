import { pool } from "../../db/pool.js";
import { getActiveTournamentId } from "../settings/service.js";
import {
  getTbdTeamId,
  loadKnockoutRowsForTournament,
  loadPredictionsMap
} from "./knockoutAdvancement.js";
import {
  knockoutExternalNum,
  matchOutcomeOfficial,
  resolveKnockoutBracketTeams,
  resolveOfficialKnockoutBracketTeams,
  type KnockoutMatchRow,
  type UserPredictionRow
} from "./knockoutBracketLogic.js";
import {
  getOfficialBonusResults,
  setOfficialBonusResults,
  type OfficialBonusResults,
  type CalculateBonusScoresResult
} from "../scoring/bonuses.js";
import { resolveKnockoutAdvancingTeamId } from "./knockoutAdvancingResolve.js";
import { loadOfficialR16SlotsMap } from "./r16Service.js";

export interface DerivedBracketBonusPicks {
  championTeamId: number | null;
  runnerUpTeamId: number | null;
  thirdPlaceTeamId: number | null;
  semifinalistTeamIds: number[];
  finalistTeamIds: number[];
}

export interface OfficialBracketBonusPicks extends DerivedBracketBonusPicks {
  /**
   * Partido (matches.id) que consagró a cada equipo: el de la ronda anterior que ganó o, si el
   * cruce se fijó a mano sin resultado, el cruce de la ronda donde aparece. Sirve para asignar el
   * premio (semifinalista/finalista) a ese partido en vez de al cuadro de bonus.
   */
  semifinalistSourceMatchIds: Record<string, number>;
  finalistSourceMatchIds: Record<string, number>;
  /** Partido de la final (consagra campeón y subcampeón) y del tercer puesto. */
  championMatchId: number | null;
  thirdPlaceMatchId: number | null;
}

function uniqueValidTeamIds(ids: Array<number | string>, tbdId: number): number[] {
  const seen = new Set<number>();
  const out: number[] = [];
  for (const raw of ids) {
    const id = Number(raw);
    if (!id || Number.isNaN(id) || id === tbdId || seen.has(id)) continue;
    seen.add(id);
    out.push(id);
  }
  return out;
}

function advancingFromPrediction(
  match: KnockoutMatchRow,
  homeId: number,
  awayId: number,
  prediction: UserPredictionRow | undefined,
  tbdId: number
): number | null {
  if (
    prediction?.predicted_home_score == null ||
    prediction?.predicted_away_score == null
  ) {
    const adv = prediction?.predicted_advancing_team_id;
    if (adv != null && adv !== tbdId && (adv === homeId || adv === awayId)) {
      return adv;
    }
    return null;
  }
  return resolveKnockoutAdvancingTeamId(match, prediction, homeId, awayId, tbdId);
}

function hasUserKnockoutPick(prediction: UserPredictionRow | undefined): boolean {
  if (!prediction) return false;
  if (prediction.predicted_advancing_team_id != null) return true;
  return prediction.predicted_home_score != null && prediction.predicted_away_score != null;
}

/** Construye el cuadro de premios a partir del bracket resuelto y las predicciones. */
export function buildDerivedBracketBonusPicks(
  rows: KnockoutMatchRow[],
  roundByMatchId: Map<number, string>,
  resolved: Map<number, { homeTeamId: number; awayTeamId: number }>,
  preds: Map<number, UserPredictionRow>,
  tbdId: number
): DerivedBracketBonusPicks {
  const advancingWinnersInRound = (roundKey: string): number[] => {
    const ids: number[] = [];
    for (const row of rows) {
      if (roundByMatchId.get(Number(row.id))?.toUpperCase() !== roundKey) continue;
      const num = knockoutExternalNum(row.external_id);
      if (num == null) continue;
      const slot = resolved.get(num);
      if (!slot) continue;
      const adv = advancingFromPrediction(
        row,
        slot.homeTeamId,
        slot.awayTeamId,
        preds.get(Number(row.id)),
        tbdId
      );
      if (adv) ids.push(adv);
    }
    return uniqueValidTeamIds(ids, tbdId);
  };

  const teamsInRoundIfPredicted = (roundKey: string): number[] => {
    const ids: number[] = [];
    for (const row of rows) {
      if (roundByMatchId.get(Number(row.id))?.toUpperCase() !== roundKey) continue;
      if (!hasUserKnockoutPick(preds.get(Number(row.id)))) continue;
      const num = knockoutExternalNum(row.external_id);
      if (num == null) continue;
      const slot = resolved.get(num);
      if (!slot) continue;
      ids.push(slot.homeTeamId, slot.awayTeamId);
    }
    return uniqueValidTeamIds(ids, tbdId);
  };

  const advancingOnlyMerge = (...roundKeys: string[]): number[] => {
    const ids: number[] = [];
    for (const key of roundKeys) {
      ids.push(...advancingWinnersInRound(key));
    }
    return uniqueValidTeamIds(ids, tbdId);
  };

  const semifinalistTeamIds = advancingOnlyMerge("SF", "R4");
  const finalistTeamIds = uniqueValidTeamIds(
    [...advancingWinnersInRound("SF"), ...teamsInRoundIfPredicted("F")],
    tbdId
  ).slice(0, 2);

  let championTeamId: number | null = null;
  let runnerUpTeamId: number | null = null;
  let thirdPlaceTeamId: number | null = null;

  for (const row of rows) {
    const round = roundByMatchId.get(Number(row.id))?.toUpperCase();
    const num = knockoutExternalNum(row.external_id);
    if (num == null) continue;
    const slot = resolved.get(num);
    if (!slot) continue;

    const homeId = Number(slot.homeTeamId);
    const awayId = Number(slot.awayTeamId);
    const adv = advancingFromPrediction(row, homeId, awayId, preds.get(Number(row.id)), tbdId);
    if (!adv) continue;

    if (round === "F") {
      championTeamId = adv;
      const other = homeId === adv ? awayId : homeId;
      runnerUpTeamId = other !== tbdId ? other : null;
    } else if (round === "TP3") {
      thirdPlaceTeamId = adv;
    }
  }

  const finalWinners = advancingWinnersInRound("F");
  if (!championTeamId && finalWinners.length === 1) {
    championTeamId = finalWinners[0];
  }

  return {
    championTeamId,
    runnerUpTeamId,
    thirdPlaceTeamId,
    semifinalistTeamIds: semifinalistTeamIds.slice(0, 4),
    finalistTeamIds: finalistTeamIds.slice(0, 2)
  };
}

/** Cuadro de premios (campeón, finalistas, etc.) a partir de predicciones en eliminatorias. */
export async function deriveBonusPicksFromUserBracket(
  userId: number
): Promise<DerivedBracketBonusPicks> {
  const empty: DerivedBracketBonusPicks = {
    championTeamId: null,
    runnerUpTeamId: null,
    thirdPlaceTeamId: null,
    semifinalistTeamIds: [],
    finalistTeamIds: []
  };

  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) return empty;

  const rows = await loadKnockoutRowsForTournament(tournamentId);
  if (rows.length === 0) return empty;

  const tbdId = await getTbdTeamId();
  const preds = await loadPredictionsMap(
    userId,
    rows.map((r) => r.id)
  );
  const { resolveUserKnockoutBracketTeams } = await import("./resolveUserKnockoutBracket.js");
  const resolved = await resolveUserKnockoutBracketTeams(userId, tournamentId);

  const roundByMatchId = new Map<number, string>();
  const roundRows = await pool.query(
    `SELECT id, round_key FROM matches WHERE tournament_id = $1 AND stage = 'KNOCKOUT'`,
    [tournamentId]
  );
  for (const r of roundRows.rows) {
    roundByMatchId.set(Number(r.id), String(r.round_key ?? ""));
  }

  return buildDerivedBracketBonusPicks(rows, roundByMatchId, resolved, preds, tbdId);
}

export async function syncUserBonusPicksFromBracket(userId: number): Promise<DerivedBracketBonusPicks> {
  const derived = await deriveBonusPicksFromUserBracket(userId);
  const existing = await pool.query(
    `SELECT top_scorer, top_assister FROM bonus_predictions WHERE user_id = $1`,
    [userId]
  );
  const topScorer = existing.rows[0]?.top_scorer ?? null;
  const topAssister = existing.rows[0]?.top_assister ?? null;

  await pool.query(
    `INSERT INTO bonus_predictions (
      user_id, champion_team_id, runner_up_team_id, third_place_team_id,
      semifinalist_team_ids, finalist_team_ids, top_scorer, top_assister
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
    ON CONFLICT (user_id) DO UPDATE SET
      champion_team_id = EXCLUDED.champion_team_id,
      runner_up_team_id = EXCLUDED.runner_up_team_id,
      third_place_team_id = EXCLUDED.third_place_team_id,
      semifinalist_team_ids = EXCLUDED.semifinalist_team_ids,
      finalist_team_ids = EXCLUDED.finalist_team_ids`,
    [
      userId,
      derived.championTeamId,
      derived.runnerUpTeamId,
      derived.thirdPlaceTeamId,
      derived.semifinalistTeamIds,
      derived.finalistTeamIds,
      topScorer,
      topAssister
    ]
  );

  return derived;
}

function advancingFromOfficial(
  match: KnockoutMatchRow,
  homeId: number,
  awayId: number,
  tbdId: number
): number | null {
  return matchOutcomeOfficial(match, homeId, awayId, tbdId).winnerId;
}

/** Campeón, finalistas, etc. según resultados reales del torneo. */
export function buildOfficialBracketBonusPicks(
  rows: KnockoutMatchRow[],
  roundByMatchId: Map<number, string>,
  resolved: Map<number, { homeTeamId: number; awayTeamId: number }>,
  tbdId: number
): OfficialBracketBonusPicks {
  // equipo → matches.id del cruce de esa ronda donde aparece.
  const participantsWithMatch = (roundKey: string): Map<number, number> => {
    const map = new Map<number, number>();
    for (const row of rows) {
      if (roundByMatchId.get(Number(row.id))?.toUpperCase() !== roundKey) continue;
      const num = knockoutExternalNum(row.external_id);
      if (num == null) continue;
      const slot = resolved.get(num);
      if (!slot) continue;
      for (const teamId of [Number(slot.homeTeamId), Number(slot.awayTeamId)]) {
        if (teamId && teamId !== tbdId && !map.has(teamId)) map.set(teamId, Number(row.id));
      }
    }
    return map;
  };

  // equipo → matches.id del partido de esa ronda que GANÓ.
  const winnersWithMatch = (roundKey: string): Map<number, number> => {
    const map = new Map<number, number>();
    for (const row of rows) {
      if (roundByMatchId.get(Number(row.id))?.toUpperCase() !== roundKey) continue;
      const num = knockoutExternalNum(row.external_id);
      if (num == null) continue;
      const slot = resolved.get(num);
      if (!slot) continue;
      const adv = advancingFromOfficial(row, slot.homeTeamId, slot.awayTeamId, tbdId);
      if (adv && adv !== tbdId && !map.has(adv)) map.set(adv, Number(row.id));
    }
    return map;
  };

  // Un equipo logra el hito solo cuando LLEGA a esa ronda: aparece en un cruce de la ronda o ganó
  // el partido de la ronda anterior. Incluir a los participantes de la ronda previa premiaría
  // antes de tiempo (p. ej. todo cuartofinalista contaría como "semifinalista"). El partido que
  // consagra el hito es el que ganó; la mera aparición en el cruce queda como respaldo para
  // cruces fijados a mano sin resultado previo.
  const semiSources = participantsWithMatch("SF");
  for (const [teamId, matchId] of winnersWithMatch("R4")) semiSources.set(teamId, matchId);
  const finalSources = participantsWithMatch("F");
  for (const [teamId, matchId] of winnersWithMatch("SF")) finalSources.set(teamId, matchId);

  const semifinalistTeamIds = uniqueValidTeamIds([...semiSources.keys()], tbdId);
  const finalistTeamIds = uniqueValidTeamIds([...finalSources.keys()], tbdId);

  let championTeamId: number | null = null;
  let runnerUpTeamId: number | null = null;
  let thirdPlaceTeamId: number | null = null;
  let championMatchId: number | null = null;
  let thirdPlaceMatchId: number | null = null;

  for (const row of rows) {
    const round = roundByMatchId.get(Number(row.id))?.toUpperCase();
    const num = knockoutExternalNum(row.external_id);
    if (num == null) continue;
    const slot = resolved.get(num);
    if (!slot) continue;

    const homeId = Number(slot.homeTeamId);
    const awayId = Number(slot.awayTeamId);
    const adv = advancingFromOfficial(row, homeId, awayId, tbdId);
    if (!adv) continue;

    if (round === "F") {
      championTeamId = adv;
      championMatchId = Number(row.id);
      const other = homeId === adv ? awayId : homeId;
      runnerUpTeamId = other !== tbdId ? other : null;
    } else if (round === "TP3") {
      thirdPlaceTeamId = adv;
      thirdPlaceMatchId = Number(row.id);
    }
  }

  const finalWinnerEntries = [...winnersWithMatch("F")];
  if (!championTeamId && finalWinnerEntries.length === 1) {
    championTeamId = finalWinnerEntries[0][0];
    championMatchId = finalWinnerEntries[0][1];
  }

  const cappedSemifinalists = semifinalistTeamIds.slice(0, 4);
  const cappedFinalists = finalistTeamIds.slice(0, 2);
  const sourcesFor = (ids: number[], map: Map<number, number>): Record<string, number> =>
    Object.fromEntries(ids.filter((id) => map.has(id)).map((id) => [String(id), map.get(id) as number]));

  return {
    championTeamId,
    runnerUpTeamId,
    thirdPlaceTeamId,
    semifinalistTeamIds: cappedSemifinalists,
    finalistTeamIds: cappedFinalists,
    semifinalistSourceMatchIds: sourcesFor(cappedSemifinalists, semiSources),
    finalistSourceMatchIds: sourcesFor(cappedFinalists, finalSources),
    championMatchId,
    thirdPlaceMatchId
  };
}

export async function deriveOfficialBonusFromRealBracket(
  tournamentId: number
): Promise<OfficialBracketBonusPicks> {
  const empty: OfficialBracketBonusPicks = {
    championTeamId: null,
    runnerUpTeamId: null,
    thirdPlaceTeamId: null,
    semifinalistTeamIds: [],
    finalistTeamIds: [],
    semifinalistSourceMatchIds: {},
    finalistSourceMatchIds: {},
    championMatchId: null,
    thirdPlaceMatchId: null
  };

  const rows = await loadKnockoutRowsForTournament(tournamentId);
  if (rows.length === 0) return empty;

  const tbdId = await getTbdTeamId();
  const resolved = resolveOfficialKnockoutBracketTeams(rows, tbdId);

  const roundByMatchId = new Map<number, string>();
  const roundRows = await pool.query(
    `SELECT id, round_key FROM matches WHERE tournament_id = $1 AND stage = 'KNOCKOUT'`,
    [tournamentId]
  );
  for (const r of roundRows.rows) {
    roundByMatchId.set(Number(r.id), String(r.round_key ?? ""));
  }

  return buildOfficialBracketBonusPicks(rows, roundByMatchId, resolved, tbdId);
}

interface BonusUpsertRow {
  userId: number;
  championTeamId: number | null;
  runnerUpTeamId: number | null;
  thirdPlaceTeamId: number | null;
  semifinalistTeamIds: number[];
  finalistTeamIds: number[];
  topScorer: string | null;
  topAssister: string | null;
}

/** Predicciones de varios usuarios en una sola consulta, agrupadas por usuario. */
async function loadPredictionsByUser(
  userIds: number[],
  matchIds: number[]
): Promise<Map<number, Map<number, UserPredictionRow>>> {
  const byUser = new Map<number, Map<number, UserPredictionRow>>();
  if (userIds.length === 0 || matchIds.length === 0) return byUser;

  const result = await pool.query(
    `SELECT user_id, match_id, predicted_home_score, predicted_away_score, predicted_advancing_team_id
     FROM predictions
     WHERE user_id = ANY($1::bigint[]) AND match_id = ANY($2::bigint[])`,
    [userIds, matchIds]
  );
  for (const row of result.rows) {
    const uid = Number(row.user_id);
    let perMatch = byUser.get(uid);
    if (!perMatch) {
      perMatch = new Map();
      byUser.set(uid, perMatch);
    }
    perMatch.set(Number(row.match_id), {
      predicted_home_score:
        row.predicted_home_score != null ? Number(row.predicted_home_score) : null,
      predicted_away_score:
        row.predicted_away_score != null ? Number(row.predicted_away_score) : null,
      predicted_advancing_team_id:
        row.predicted_advancing_team_id != null ? Number(row.predicted_advancing_team_id) : null
    });
  }
  return byUser;
}

/** Upsert masivo del cuadro de premios; conserva goleador/asistidor igual que la versión por usuario. */
async function upsertBonusPredictionsBatch(rows: BonusUpsertRow[]): Promise<void> {
  if (rows.length === 0) return;
  const CHUNK = 500;
  for (let i = 0; i < rows.length; i += CHUNK) {
    const chunk = rows.slice(i, i + CHUNK);
    const params: unknown[] = [];
    const tuples: string[] = [];
    for (const r of chunk) {
      const base = params.length;
      tuples.push(
        `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}::bigint[], $${base + 6}::bigint[], $${base + 7}, $${base + 8})`
      );
      params.push(
        r.userId,
        r.championTeamId,
        r.runnerUpTeamId,
        r.thirdPlaceTeamId,
        r.semifinalistTeamIds,
        r.finalistTeamIds,
        r.topScorer,
        r.topAssister
      );
    }
    await pool.query(
      `INSERT INTO bonus_predictions (
        user_id, champion_team_id, runner_up_team_id, third_place_team_id,
        semifinalist_team_ids, finalist_team_ids, top_scorer, top_assister
      ) VALUES ${tuples.join(", ")}
      ON CONFLICT (user_id) DO UPDATE SET
        champion_team_id = EXCLUDED.champion_team_id,
        runner_up_team_id = EXCLUDED.runner_up_team_id,
        third_place_team_id = EXCLUDED.third_place_team_id,
        semifinalist_team_ids = EXCLUDED.semifinalist_team_ids,
        finalist_team_ids = EXCLUDED.finalist_team_ids`,
      params
    );
  }
}

/**
 * Versión batcheada de `syncUserBonusPicksFromBracket` para TODOS los usuarios: carga una sola vez
 * los datos constantes del torneo (rows del cuadro, TBD, slots R16 oficiales, ronda por partido) y
 * todas las predicciones en una consulta, resuelve cada cuadro en memoria y escribe en lote. El
 * resultado por usuario es idéntico al de la versión por usuario, pero sin las ~10 consultas/usuario.
 */
export async function syncAllUsersBonusPicksFromBracket(): Promise<number> {
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) return 0;

  const rows = await loadKnockoutRowsForTournament(tournamentId);
  if (rows.length === 0) return 0;

  const tbdId = await getTbdTeamId();
  const matchIds = rows.map((r) => r.id);
  const r16Official = await loadOfficialR16SlotsMap(tournamentId);

  const roundByMatchId = new Map<number, string>();
  const roundRows = await pool.query(
    `SELECT id, round_key FROM matches WHERE tournament_id = $1 AND stage = 'KNOCKOUT'`,
    [tournamentId]
  );
  for (const r of roundRows.rows) {
    roundByMatchId.set(Number(r.id), String(r.round_key ?? ""));
  }

  const usersResult = await pool.query(`SELECT id FROM users WHERE role = 'USER'`);
  const userIds = usersResult.rows.map((u) => Number(u.id));
  if (userIds.length === 0) return 0;

  const predsByUser = await loadPredictionsByUser(userIds, matchIds);

  const extrasByUser = new Map<number, { topScorer: string | null; topAssister: string | null }>();
  const extrasResult = await pool.query(
    `SELECT user_id, top_scorer, top_assister FROM bonus_predictions WHERE user_id = ANY($1::bigint[])`,
    [userIds]
  );
  for (const r of extrasResult.rows) {
    extrasByUser.set(Number(r.user_id), {
      topScorer: (r.top_scorer as string | null) ?? null,
      topAssister: (r.top_assister as string | null) ?? null
    });
  }

  const emptyPreds = new Map<number, UserPredictionRow>();
  const upserts: BonusUpsertRow[] = userIds.map((userId) => {
    const preds = predsByUser.get(userId) ?? emptyPreds;
    const resolved = resolveKnockoutBracketTeams(rows, preds, tbdId, r16Official);
    const derived = buildDerivedBracketBonusPicks(rows, roundByMatchId, resolved, preds, tbdId);
    const extras = extrasByUser.get(userId);
    return {
      userId,
      championTeamId: derived.championTeamId,
      runnerUpTeamId: derived.runnerUpTeamId,
      thirdPlaceTeamId: derived.thirdPlaceTeamId,
      semifinalistTeamIds: derived.semifinalistTeamIds,
      finalistTeamIds: derived.finalistTeamIds,
      topScorer: extras?.topScorer ?? null,
      topAssister: extras?.topAssister ?? null
    };
  });

  await upsertBonusPredictionsBatch(upserts);
  return userIds.length;
}

/** Actualiza resultados oficiales de bonos (finalistas reales) y puntúa vs cuadro de cada usuario. */
export async function syncOfficialBonusResultsAndScore(): Promise<
  CalculateBonusScoresResult & { official: OfficialBonusResults }
> {
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) {
    return {
      official: {},
      usersScored: 0,
      officialFinalists: { ids: [], names: [] },
      officialSemifinalists: { ids: [], names: [] },
      finalistComparisons: [],
      semifinalistComparisons: []
    };
  }

  const derived = await deriveOfficialBonusFromRealBracket(tournamentId);
  const prev = await getOfficialBonusResults();
  const official: OfficialBonusResults = {
    ...prev,
    championTeamId: derived.championTeamId,
    runnerUpTeamId: derived.runnerUpTeamId,
    thirdPlaceTeamId: derived.thirdPlaceTeamId,
    semifinalistTeamIds: derived.semifinalistTeamIds,
    finalistTeamIds: derived.finalistTeamIds,
    semifinalistSourceMatchIds: derived.semifinalistSourceMatchIds,
    finalistSourceMatchIds: derived.finalistSourceMatchIds,
    championMatchId: derived.championMatchId,
    thirdPlaceMatchId: derived.thirdPlaceMatchId
  };
  await setOfficialBonusResults(official);

  await syncAllUsersBonusPicksFromBracket();

  const { calculateBonusScores } = await import("../scoring/bonuses.js");
  const scoring = await calculateBonusScores();

  return { official, ...scoring };
}
