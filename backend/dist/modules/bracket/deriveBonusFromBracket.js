import { pool } from "../../db/pool.js";
import { getActiveTournamentId } from "../settings/service.js";
import { getTbdTeamId, loadKnockoutRowsForTournament, loadPredictionsMap } from "./knockoutAdvancement.js";
import { knockoutExternalNum, resolveKnockoutBracketTeams } from "./knockoutBracketLogic.js";
import { resolveKnockoutAdvancingTeamId } from "./knockoutAdvancingResolve.js";
function uniqueValidTeamIds(ids, tbdId) {
    const seen = new Set();
    const out = [];
    for (const id of ids) {
        if (!id || id === tbdId || seen.has(id))
            continue;
        seen.add(id);
        out.push(id);
    }
    return out;
}
function advancingFromPrediction(match, homeId, awayId, prediction, tbdId) {
    if (prediction?.predicted_home_score == null ||
        prediction?.predicted_away_score == null) {
        return null;
    }
    return resolveKnockoutAdvancingTeamId(match, prediction, homeId, awayId, tbdId);
}
/** Cuadro de premios (campeón, finalistas, etc.) a partir de predicciones en eliminatorias. */
export async function deriveBonusPicksFromUserBracket(userId) {
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId) {
        return {
            championTeamId: null,
            runnerUpTeamId: null,
            thirdPlaceTeamId: null,
            semifinalistTeamIds: [],
            finalistTeamIds: []
        };
    }
    const rows = await loadKnockoutRowsForTournament(tournamentId);
    if (rows.length === 0) {
        return {
            championTeamId: null,
            runnerUpTeamId: null,
            thirdPlaceTeamId: null,
            semifinalistTeamIds: [],
            finalistTeamIds: []
        };
    }
    const tbdId = await getTbdTeamId();
    const preds = await loadPredictionsMap(userId, rows.map((r) => r.id));
    const resolved = resolveKnockoutBracketTeams(rows, preds, tbdId);
    const roundByMatchId = new Map();
    const roundRows = await pool.query(`SELECT id, round_key FROM matches WHERE tournament_id = $1 AND stage = 'KNOCKOUT'`, [tournamentId]);
    for (const r of roundRows.rows) {
        roundByMatchId.set(Number(r.id), String(r.round_key ?? ""));
    }
    const teamsInRound = (roundKey) => {
        const ids = [];
        for (const row of rows) {
            if (roundByMatchId.get(row.id)?.toUpperCase() !== roundKey)
                continue;
            const num = knockoutExternalNum(row.external_id);
            if (num == null)
                continue;
            const slot = resolved.get(num);
            if (!slot)
                continue;
            ids.push(slot.homeTeamId, slot.awayTeamId);
        }
        return uniqueValidTeamIds(ids, tbdId);
    };
    const semifinalistTeamIds = teamsInRound("SF");
    const finalistTeamIds = teamsInRound("F");
    let championTeamId = null;
    let runnerUpTeamId = null;
    let thirdPlaceTeamId = null;
    for (const row of rows) {
        const round = roundByMatchId.get(row.id)?.toUpperCase();
        const num = knockoutExternalNum(row.external_id);
        if (num == null)
            continue;
        const slot = resolved.get(num);
        if (!slot)
            continue;
        const homeId = slot.homeTeamId;
        const awayId = slot.awayTeamId;
        const adv = advancingFromPrediction(row, homeId, awayId, preds.get(row.id), tbdId);
        if (!adv)
            continue;
        if (round === "F") {
            championTeamId = adv;
            const other = homeId === adv ? awayId : homeId;
            runnerUpTeamId = other !== tbdId ? other : null;
        }
        else if (round === "TP3") {
            thirdPlaceTeamId = adv;
        }
    }
    return {
        championTeamId,
        runnerUpTeamId,
        thirdPlaceTeamId,
        semifinalistTeamIds,
        finalistTeamIds
    };
}
export async function syncUserBonusPicksFromBracket(userId) {
    const derived = await deriveBonusPicksFromUserBracket(userId);
    const existing = await pool.query(`SELECT top_scorer, top_assister FROM bonus_predictions WHERE user_id = $1`, [userId]);
    const topScorer = existing.rows[0]?.top_scorer ?? null;
    const topAssister = existing.rows[0]?.top_assister ?? null;
    await pool.query(`INSERT INTO bonus_predictions (
      user_id, champion_team_id, runner_up_team_id, third_place_team_id,
      semifinalist_team_ids, finalist_team_ids, top_scorer, top_assister
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
    ON CONFLICT (user_id) DO UPDATE SET
      champion_team_id = EXCLUDED.champion_team_id,
      runner_up_team_id = EXCLUDED.runner_up_team_id,
      third_place_team_id = EXCLUDED.third_place_team_id,
      semifinalist_team_ids = EXCLUDED.semifinalist_team_ids,
      finalist_team_ids = EXCLUDED.finalist_team_ids`, [
        userId,
        derived.championTeamId,
        derived.runnerUpTeamId,
        derived.thirdPlaceTeamId,
        derived.semifinalistTeamIds,
        derived.finalistTeamIds,
        topScorer,
        topAssister
    ]);
    return derived;
}
