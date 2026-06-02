import { pool } from "../../db/pool.js";
import { getActiveTournamentId } from "../settings/service.js";
import { computeOfficialFifaFromResults } from "./fifaFromStandings.js";
import { WC2026_R16_FIXTURES } from "./r16Slots.js";
import { groupLetterFromName } from "./groupLetter.js";
import { assignThirdPlacesToR32Slots } from "./thirdPlaceResolver.js";
import { r4NumForR16, r8NumForR16, WC2026_R32_TO_R16 } from "./wc2026R32Fixtures.js";
import { enrichKnockoutAdvancingOnRows, loadPredictionsMap } from "./knockoutAdvancement.js";
import { resolveKnockoutAdvancingTeamId } from "./knockoutAdvancingResolve.js";
import { knockoutExternalNum } from "./knockoutBracketLogic.js";
export { computeOfficialFifaFromResults };
async function getTbdTeamId() {
    const row = await pool.query("SELECT id FROM teams WHERE external_id = 'wc2026-tbd' LIMIT 1");
    if (!row.rows[0])
        throw new Error("Equipo TBD no encontrado; importa el cuadro eliminatorio");
    return row.rows[0].id;
}
function poolFromFifa(fifa, tbdTeamId) {
    const byGroup = new Map();
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
function resolveSlotTeamId(slot, pool) {
    if (slot.kind === "third_combo" && slot.matchNum) {
        return pool.thirdByMatch.get(slot.matchNum) ?? null;
    }
    const g = pool.byGroup.get(slot.group.toUpperCase());
    if (!g)
        return null;
    if (slot.kind === "first")
        return g.first;
    return g.second;
}
export function getBracketTreeMeta() {
    return {
        pairs: WC2026_R32_TO_R16.map((link) => ({
            side: link.side,
            r32Nums: link.r32Nums,
            r16Num: link.r16Num,
            r8Num: r8NumForR16(link.r16Num) ?? 0
        }))
    };
}
function enrichFixtureMeta(fx, base) {
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
export function resolveR16FromPool(fixtures, pool, _teamById) {
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
function teamFromMap(teamMap, teamId) {
    const t = teamMap.get(teamId);
    return t ? { ...t, teamId } : null;
}
function resolveMatchTeams(fx, pool, teamMap) {
    const homeId = resolveSlotTeamId(fx.homeSlot, pool);
    const awayId = resolveSlotTeamId(fx.awaySlot, pool);
    const home = homeId && homeId !== pool.tbdTeamId ? teamFromMap(teamMap, homeId) : null;
    let away = awayId && awayId !== pool.tbdTeamId ? teamFromMap(teamMap, awayId) : null;
    let awaySlotLabel = fx.awaySlotLabel;
    if (fx.awaySlot.kind === "third_combo" && away) {
        awaySlotLabel = `3º Grupo ${away.groupName ?? "?"}`;
    }
    return { home, away, awaySlotLabel };
}
export function buildQualifiersSummary(fifa, thirdByMatch, teamMap) {
    const assignmentByTeam = new Map();
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
async function loadTeamMap(tournamentId) {
    const teamsResult = await pool.query(`SELECT t.id, t.name, t.short_name, t.logo_url, g.name AS group_name
    FROM teams t
    JOIN standings s ON s.team_id = t.id AND s.tournament_id = $1
    JOIN groups g ON g.id = s.group_id`, [tournamentId]);
    return new Map(teamsResult.rows.map((r) => [
        r.id,
        {
            teamId: r.id,
            name: r.name,
            shortName: r.short_name,
            logoUrl: r.logo_url,
            groupName: r.group_name
        }
    ]));
}
async function loadR16MatchRows(tournamentId) {
    const tbdId = await getTbdTeamId();
    const result = await pool.query(`SELECT m.id, m.external_id, m.starts_at, m.round_label,
      m.home_team_id, m.away_team_id,
      ht.name AS home_name, ht.short_name AS home_short, ht.logo_url AS home_logo,
      at.name AS away_name, at.short_name AS away_short, at.logo_url AS away_logo
    FROM matches m
    JOIN teams ht ON ht.id = m.home_team_id
    JOIN teams at ON at.id = m.away_team_id
    WHERE m.tournament_id = $1 AND m.stage = 'KNOCKOUT' AND m.round_key = 'R16'
    ORDER BY m.starts_at ASC, m.id ASC`, [tournamentId]);
    return { rows: result.rows, tbdId };
}
function externalNumFromId(externalId) {
    const m = externalId.match(/wc2026-ko-(\d+)/);
    return m ? Number(m[1]) : 0;
}
function fixtureForExternalNum(num) {
    return WC2026_R16_FIXTURES.find((f) => f.externalNum === num);
}
function rowToBracketMatch(row, tbdId, groupNames) {
    const extNum = externalNumFromId(row.external_id);
    const fx = fixtureForExternalNum(extNum);
    const homeId = row.home_team_id;
    const awayId = row.away_team_id;
    const homeOfficial = homeId !== tbdId;
    const awayOfficial = awayId !== tbdId;
    if (!fx) {
        return {
            matchId: row.id,
            matchNumber: 0,
            externalNum: extNum,
            label: row.round_label,
            homeSlotLabel: "",
            awaySlotLabel: "",
            startsAt: row.starts_at.toISOString(),
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
        matchId: row.id,
        homeSlotLabel: fx.homeSlotLabel,
        awaySlotLabel: fx.awaySlotLabel,
        startsAt: row.starts_at.toISOString(),
        isOfficial: homeOfficial && awayOfficial,
        home: homeOfficial
            ? {
                teamId: homeId,
                name: row.home_name,
                shortName: row.home_short,
                logoUrl: row.home_logo,
                groupName: groupNames.get(homeId) ?? null
            }
            : null,
        away: awayOfficial
            ? {
                teamId: awayId,
                name: row.away_name,
                shortName: row.away_short,
                logoUrl: row.away_logo,
                groupName: groupNames.get(awayId) ?? null
            }
            : null
    });
}
/** Cuadro oficial desde partidos R16 en BD. */
export async function getOfficialR16Bracket() {
    const tournamentId = await getActiveTournamentId();
    const tree = getBracketTreeMeta();
    if (!tournamentId)
        return { matches: [], hasKnockout: false, tree, qualifiers: null };
    const { rows, tbdId } = await loadR16MatchRows(tournamentId);
    if (rows.length === 0)
        return { matches: [], hasKnockout: false, tree, qualifiers: null };
    let qualifiers = null;
    try {
        const fifa = await computeOfficialFifaFromResults();
        const poolData = poolFromFifa(fifa, tbdId);
        const teamMap = await loadTeamMap(tournamentId);
        qualifiers = buildQualifiersSummary(fifa, poolData.thirdByMatch, teamMap);
    }
    catch {
        qualifiers = null;
    }
    const teamMap = await loadTeamMap(tournamentId);
    const groupNames = new Map();
    for (const [id, t] of teamMap)
        groupNames.set(id, t.groupName);
    const enrichRows = rows.map((row) => ({
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
                m.nextRoundLabel = enriched.nextRoundLabel ?? "octavos de final";
            }
        }
        return m;
    });
    matches.sort((a, b) => a.matchNumber - b.matchNumber);
    return { matches, hasKnockout: true, tree, qualifiers };
}
export async function applyR16PairingsToMatches(pairings) {
    const tbdId = await getTbdTeamId();
    for (const p of pairings) {
        if (p.homeTeamId === tbdId || p.awayTeamId === tbdId) {
            throw new Error("Selecciona equipos reales, no «Por definir»");
        }
        if (p.homeTeamId === p.awayTeamId) {
            throw new Error("Local y visitante no pueden ser el mismo equipo");
        }
        await pool.query(`UPDATE matches SET home_team_id = $1, away_team_id = $2, updated_at = NOW()
      WHERE id = $3 AND round_key = 'R16'`, [p.homeTeamId, p.awayTeamId, p.matchId]);
    }
}
export async function autoFillOfficialR16FromResults() {
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId)
        throw new Error("No hay torneo activo");
    const fifa = await computeOfficialFifaFromResults();
    const tbdId = await getTbdTeamId();
    const poolData = poolFromFifa(fifa, tbdId);
    const teamMap = await loadTeamMap(tournamentId);
    const qualifiers = buildQualifiersSummary(fifa, poolData.thirdByMatch, teamMap);
    const resolved = resolveR16FromPool(WC2026_R16_FIXTURES, poolData, teamMap);
    const { rows } = await loadR16MatchRows(tournamentId);
    const pairings = [];
    const missing = [];
    for (const row of rows) {
        const extNum = externalNumFromId(row.external_id);
        const fx = fixtureForExternalNum(extNum);
        if (!fx)
            continue;
        const slot = resolved.find((r) => r.matchNumber === fx.matchNumber);
        if (!slot?.homeTeamId || !slot?.awayTeamId) {
            const reasons = [];
            if (!slot?.homeTeamId)
                reasons.push(`falta local (${fx.homeSlotLabel})`);
            if (!slot?.awayTeamId) {
                reasons.push(fx.awaySlot.kind === "third_combo"
                    ? `falta 3º (${fx.awaySlotLabel}) — ¿8 mejores terceros calculados?`
                    : `falta visitante (${fx.awaySlotLabel})`);
            }
            missing.push({ matchNum: extNum, reason: reasons.join("; ") });
            continue;
        }
        pairings.push({
            matchId: row.id,
            homeTeamId: slot.homeTeamId,
            awayTeamId: slot.awayTeamId
        });
    }
    if (pairings.length === 0) {
        throw new Error(`No se pudo armar ningún cruce. Partidos de grupo finalizados: ${qualifiers.finishedGroupMatches}. ` +
            `Grupos con tabla completa: ${qualifiers.groupsWithFullTable}/12. ` +
            `Mejores terceros: ${qualifiers.bestThirds.length}/8. ` +
            `Terceros asignados a ranuras: ${qualifiers.thirdSlotsAssigned}/8. ` +
            `Finaliza más partidos de grupos o completa el cuadro manualmente.`);
    }
    await applyR16PairingsToMatches(pairings);
    return { updated: pairings.length, total: rows.length, missing, qualifiers };
}
export async function getPredictedR16Bracket(userId) {
    const { computeUserQualifiersFromPredictions } = await import("../qualifiers/fromPredictions.js");
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId) {
        const emptyQualifiers = {
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
    const r16Db = await pool.query(`SELECT id, external_id, status, home_team_id, away_team_id, home_score, away_score, winner_team_id
    FROM matches
    WHERE tournament_id = $1 AND stage = 'KNOCKOUT' AND round_key = 'R16'`, [tournamentId]);
    const enrichRows = r16Db.rows.map((r) => ({
        ...r,
        stage: "KNOCKOUT",
        round_key: "R16"
    }));
    await enrichKnockoutAdvancingOnRows(userId, enrichRows);
    const preds = await loadPredictionsMap(userId, r16Db.rows.map((r) => Number(r.id)));
    const matches = WC2026_R16_FIXTURES.map((fx) => {
        const slot = resolved.find((r) => r.matchNumber === fx.matchNumber);
        const officialMatch = official.matches.find((m) => m.externalNum === fx.externalNum);
        const { home, away, awaySlotLabel } = resolveMatchTeams(fx, poolData, teamMap);
        const dbRow = r16Db.rows.find((r) => knockoutExternalNum(r.external_id) === fx.externalNum);
        const enriched = enrichRows.find((r) => knockoutExternalNum(r.external_id) === fx.externalNum);
        let advancingTeam = null;
        let advancingViaPenalties = false;
        let nextRoundLabel = "octavos de final";
        if (enriched?.advancingTeamId) {
            const t = teamMap.get(Number(enriched.advancingTeamId));
            if (t)
                advancingTeam = { ...t, teamId: Number(enriched.advancingTeamId) };
            advancingViaPenalties = Boolean(enriched.advancingViaPenalties);
            nextRoundLabel = enriched.nextRoundLabel ?? nextRoundLabel;
        }
        else if (dbRow && home && away) {
            const ko = {
                id: Number(dbRow.id),
                external_id: dbRow.external_id,
                status: dbRow.status,
                home_team_id: Number(dbRow.home_team_id),
                away_team_id: Number(dbRow.away_team_id),
                home_score: dbRow.home_score,
                away_score: dbRow.away_score,
                winner_team_id: dbRow.winner_team_id
            };
            const advId = resolveKnockoutAdvancingTeamId(ko, preds.get(ko.id), slot?.homeTeamId ?? ko.home_team_id, slot?.awayTeamId ?? ko.away_team_id, tbdId);
            if (advId) {
                const t = teamMap.get(advId);
                if (t)
                    advancingTeam = { ...t, teamId: advId };
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
export async function listQualifiedTeamsForR16() {
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId)
        return [];
    const teamMap = await loadTeamMap(tournamentId);
    return [...teamMap.values()].sort((a, b) => (a.groupName ?? "").localeCompare(b.groupName ?? "") || a.name.localeCompare(b.name, "es"));
}
