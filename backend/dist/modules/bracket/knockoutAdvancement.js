import { pool } from "../../db/pool.js";
import { feedsReferencing, knockoutExternalNum, KNOCKOUT_MATCH_ORDER, matchOutcome, resolveKnockoutBracketTeams } from "./knockoutBracketLogic.js";
import { resolveKnockoutAdvancingTeamId } from "./knockoutAdvancingResolve.js";
export { KNOCKOUT_MATCH_ORDER, KNOCKOUT_SLOT_FEEDS, knockoutExternalNum, matchOutcome, parseSlotFeed, resolveKnockoutBracketTeams } from "./knockoutBracketLogic.js";
export async function getTbdTeamId() {
    const row = await pool.query("SELECT id FROM teams WHERE external_id = 'wc2026-tbd' LIMIT 1");
    if (!row.rows[0])
        throw new Error("Equipo TBD no encontrado; importa el cuadro eliminatorio");
    return row.rows[0].id;
}
export async function propagateOfficialKnockoutAdvancement(matchId) {
    const row = await pool.query(`SELECT id, external_id, tournament_id, stage, status,
      home_team_id, away_team_id, home_score, away_score, winner_team_id
    FROM matches WHERE id = $1`, [matchId]);
    const match = row.rows[0];
    if (!match || match.stage !== "KNOCKOUT" || match.status !== "FINISHED")
        return 0;
    const feederNum = knockoutExternalNum(match.external_id);
    if (feederNum == null)
        return 0;
    const tbdId = await getTbdTeamId();
    const { winnerId, loserId } = matchOutcome(match, null, match.home_team_id, match.away_team_id, tbdId);
    if (!winnerId)
        return 0;
    if (!match.winner_team_id || match.winner_team_id === tbdId) {
        await pool.query(`UPDATE matches SET winner_team_id = $1, updated_at = NOW() WHERE id = $2`, [
            winnerId,
            matchId
        ]);
    }
    let updated = 0;
    for (const ref of feedsReferencing(feederNum)) {
        const teamId = ref.feed.type === "winner" ? winnerId : loserId;
        if (!teamId || teamId === tbdId)
            continue;
        const col = ref.side === "home" ? "home_team_id" : "away_team_id";
        const result = await pool.query(`UPDATE matches SET ${col} = $1, updated_at = NOW()
      WHERE tournament_id = $2 AND external_id = $3
      RETURNING id`, [teamId, match.tournament_id, `wc2026-ko-${ref.targetNum}`]);
        updated += result.rowCount ?? 0;
    }
    return updated;
}
export async function loadKnockoutRowsForTournament(tournamentId) {
    const result = await pool.query(`SELECT id, external_id, status, home_team_id, away_team_id, home_score, away_score, winner_team_id
    FROM matches
    WHERE tournament_id = $1 AND stage = 'KNOCKOUT'
    ORDER BY starts_at ASC`, [tournamentId]);
    return result.rows;
}
export async function loadPredictionsMap(userId, matchIds) {
    if (matchIds.length === 0)
        return new Map();
    const result = await pool.query(`SELECT match_id, predicted_home_score, predicted_away_score, predicted_advancing_team_id
    FROM predictions WHERE user_id = $1 AND match_id = ANY($2::bigint[])`, [userId, matchIds]);
    const map = new Map();
    for (const row of result.rows) {
        map.set(Number(row.match_id), {
            predicted_home_score: row.predicted_home_score,
            predicted_away_score: row.predicted_away_score,
            predicted_advancing_team_id: row.predicted_advancing_team_id
        });
    }
    return map;
}
export async function applyResolvedTeamsToMatchRows(userId, rows) {
    const koRows = rows.filter((r) => r.stage === "KNOCKOUT");
    if (koRows.length === 0)
        return;
    const tbdId = await getTbdTeamId();
    const knockRows = koRows.map((r) => ({
        id: Number(r.id),
        external_id: r.external_id,
        status: r.status,
        home_team_id: Number(r.home_team_id),
        away_team_id: Number(r.away_team_id),
        home_score: r.home_score,
        away_score: r.away_score,
        winner_team_id: r.winner_team_id
    }));
    const preds = await loadPredictionsMap(userId, knockRows.map((r) => r.id));
    const resolved = resolveKnockoutBracketTeams(knockRows, preds, tbdId);
    const teamIds = [];
    for (const row of koRows) {
        const num = knockoutExternalNum(row.external_id);
        if (num == null)
            continue;
        const slot = resolved.get(num);
        if (!slot)
            continue;
        row.home_team_id = slot.homeTeamId;
        row.away_team_id = slot.awayTeamId;
        teamIds.push(slot.homeTeamId, slot.awayTeamId);
    }
    const names = await loadTeamNames(teamIds);
    for (const row of koRows) {
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
export async function syncAllOfficialKnockoutAdvancement(tournamentId) {
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
function nextRoundKeyLabel(roundKey) {
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
export async function enrichKnockoutAdvancingOnRows(userId, rows) {
    const koRows = rows.filter((r) => r.stage === "KNOCKOUT");
    if (koRows.length === 0)
        return;
    const tbdId = await getTbdTeamId();
    const knockRows = koRows.map((r) => ({
        id: Number(r.id),
        external_id: r.external_id,
        status: r.status,
        home_team_id: Number(r.home_team_id),
        away_team_id: Number(r.away_team_id),
        home_score: r.home_score,
        away_score: r.away_score,
        winner_team_id: r.winner_team_id
    }));
    const preds = userId != null
        ? await loadPredictionsMap(userId, knockRows.map((r) => r.id))
        : new Map();
    const teamIds = [];
    for (let i = 0; i < koRows.length; i++) {
        const row = koRows[i];
        const ko = knockRows[i];
        const pred = preds.get(ko.id);
        const advId = resolveKnockoutAdvancingTeamId(ko, pred, ko.home_team_id, ko.away_team_id, tbdId);
        const homeScore = ko.status === "FINISHED" ? ko.home_score : pred?.predicted_home_score ?? null;
        const awayScore = ko.status === "FINISHED" ? ko.away_score : pred?.predicted_away_score ?? null;
        const isDraw = homeScore != null && awayScore != null && homeScore === awayScore;
        row.advancingTeamId = advId;
        row.advancingViaPenalties = Boolean(advId && isDraw && (ko.status === "FINISHED" || pred != null));
        row.nextRoundLabel = nextRoundKeyLabel(row.round_key);
        if (advId)
            teamIds.push(advId);
    }
    const names = await loadTeamNames(teamIds);
    for (const row of koRows) {
        const id = row.advancingTeamId;
        if (!id)
            continue;
        const t = names.get(id);
        if (t) {
            row.advancingTeamName = t.name;
            row.advancingTeamLogoUrl = t.logoUrl;
        }
    }
}
export async function loadTeamNames(teamIds) {
    const unique = [...new Set(teamIds.filter((id) => id > 0))];
    if (unique.length === 0)
        return new Map();
    const result = await pool.query(`SELECT id, name, logo_url FROM teams WHERE id = ANY($1::bigint[])`, [
        unique
    ]);
    return new Map(result.rows.map((r) => [
        Number(r.id),
        { name: r.name, logoUrl: r.logo_url }
    ]));
}
