import { pool } from "../../db/pool.js";
import { getActiveTournamentId } from "../settings/service.js";
import {
  getTbdTeamId,
  loadKnockoutRowsForTournament,
  loadPredictionsMap
} from "./knockoutAdvancement.js";
import {
  knockoutExternalNum,
  resolveKnockoutBracketTeams,
  type KnockoutMatchRow,
  type UserPredictionRow
} from "./knockoutBracketLogic.js";
import { resolveKnockoutAdvancingTeamId } from "./knockoutAdvancingResolve.js";

export interface DerivedBracketBonusPicks {
  championTeamId: number | null;
  runnerUpTeamId: number | null;
  thirdPlaceTeamId: number | null;
  semifinalistTeamIds: number[];
  finalistTeamIds: number[];
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

/** Construye el cuadro de premios a partir del bracket resuelto y las predicciones. */
export function buildDerivedBracketBonusPicks(
  rows: KnockoutMatchRow[],
  roundByMatchId: Map<number, string>,
  resolved: Map<number, { homeTeamId: number; awayTeamId: number }>,
  preds: Map<number, UserPredictionRow>,
  tbdId: number
): DerivedBracketBonusPicks {
  const teamsInRound = (roundKey: string): number[] => {
    const ids: number[] = [];
    for (const row of rows) {
      if (roundByMatchId.get(Number(row.id))?.toUpperCase() !== roundKey) continue;
      const num = knockoutExternalNum(row.external_id);
      if (num == null) continue;
      const slot = resolved.get(num);
      if (!slot) continue;
      ids.push(slot.homeTeamId, slot.awayTeamId);
    }
    return uniqueValidTeamIds(ids, tbdId);
  };

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

  const mergeRounds = (...roundKeys: string[]): number[] => {
    const ids: number[] = [];
    for (const key of roundKeys) {
      ids.push(...teamsInRound(key), ...advancingWinnersInRound(key));
    }
    return uniqueValidTeamIds(ids, tbdId);
  };

  const semifinalistTeamIds = mergeRounds("SF", "R4");
  const finalistTeamIds = mergeRounds("F", "SF");

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
  const resolved = resolveKnockoutBracketTeams(rows, preds, tbdId);

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
