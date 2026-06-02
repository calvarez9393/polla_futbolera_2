import { pool } from "../../db/pool.js";
import { getActiveTournamentId } from "../settings/service.js";
import { recalculateGroupStandings } from "../standings/recalculate.js";
import { groupQualificationFromStandings, resolveFifaQualifiers } from "../standings/simulate.js";
/** Tablas oficiales desde partidos GROUP finalizados (vía standings en BD). */
export async function computeOfficialFifaFromResults() {
    const tournamentId = await getActiveTournamentId();
    if (!tournamentId) {
        return {
            groups: [],
            directQualifiers: [],
            bestThirds: [],
            allThirdsRanked: [],
            finishedGroupMatches: 0,
            groupsWithFullTable: 0
        };
    }
    const groupsResult = await pool.query(`SELECT g.id, g.name FROM groups g WHERE g.tournament_id = $1 ORDER BY g.name`, [tournamentId]);
    const teamNames = new Map();
    const groups = [];
    let finishedGroupMatches = 0;
    let groupsWithFullTable = 0;
    for (const g of groupsResult.rows) {
        const groupId = g.id;
        const groupName = g.name;
        await recalculateGroupStandings(groupId);
        const teamsResult = await pool.query(`SELECT s.team_id, s.rank, s.points, s.played, s.won, s.draw, s.lost,
        s.goals_for, s.goals_against, s.goal_diff, t.name
      FROM standings s
      JOIN teams t ON t.id = s.team_id
      WHERE s.group_id = $1
      ORDER BY s.rank`, [groupId]);
        const teamIds = teamsResult.rows.map((r) => r.team_id);
        for (const r of teamsResult.rows) {
            teamNames.set(r.team_id, r.name);
        }
        const matchesResult = await pool.query(`SELECT home_team_id, away_team_id, home_score, away_score
      FROM matches
      WHERE group_id = $1 AND stage = 'GROUP' AND status = 'FINISHED'
        AND home_score IS NOT NULL AND away_score IS NOT NULL`, [groupId]);
        finishedGroupMatches += matchesResult.rows.length;
        const expectedPerGroup = await pool.query(`SELECT COUNT(*)::int AS c FROM matches WHERE group_id = $1 AND stage = 'GROUP'`, [groupId]);
        const expected = expectedPerGroup.rows[0]?.c;
        if (expected > 0 && matchesResult.rows.length >= expected) {
            groupsWithFullTable += 1;
        }
        const matchInputs = matchesResult.rows.map((row) => ({
            homeTeamId: row.home_team_id,
            awayTeamId: row.away_team_id,
            homeScore: row.home_score,
            awayScore: row.away_score
        }));
        const simulated = groupQualificationFromStandings(groupId, groupName, teamIds, matchInputs, teamNames);
        // Preferir posiciones ya guardadas en standings (tras recalculate)
        const byRank = teamsResult.rows;
        groups.push({
            ...simulated,
            first: byRank[0]?.team_id ?? simulated.first,
            second: byRank[1]?.team_id ?? simulated.second,
            third: byRank[2]?.team_id ?? simulated.third,
            fourth: byRank[3]?.team_id ?? simulated.fourth
        });
    }
    const fifa = resolveFifaQualifiers(groups, teamNames);
    return { ...fifa, finishedGroupMatches, groupsWithFullTable };
}
