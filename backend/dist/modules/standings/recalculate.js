import { pool } from "../../db/pool.js";
/** Recalcula la tabla de un grupo según partidos GROUP finalizados. */
export async function recalculateGroupStandings(groupId) {
    const teamsResult = await pool.query("SELECT team_id FROM standings WHERE group_id = $1", [groupId]);
    if (teamsResult.rows.length === 0)
        return;
    const stats = new Map();
    for (const row of teamsResult.rows) {
        stats.set(row.team_id, {
            played: 0,
            won: 0,
            draw: 0,
            lost: 0,
            goalsFor: 0,
            goalsAgainst: 0,
            points: 0
        });
    }
    const matches = await pool.query(`SELECT home_team_id, away_team_id, home_score, away_score
    FROM matches
    WHERE group_id = $1 AND stage = 'GROUP' AND status = 'FINISHED'
      AND home_score IS NOT NULL AND away_score IS NOT NULL`, [groupId]);
    for (const m of matches.rows) {
        const homeId = m.home_team_id;
        const awayId = m.away_team_id;
        const home = stats.get(homeId);
        const away = stats.get(awayId);
        if (!home || !away)
            continue;
        const hs = m.home_score;
        const as = m.away_score;
        home.played += 1;
        away.played += 1;
        home.goalsFor += hs;
        home.goalsAgainst += as;
        away.goalsFor += as;
        away.goalsAgainst += hs;
        if (hs > as) {
            home.won += 1;
            home.points += 3;
            away.lost += 1;
        }
        else if (hs < as) {
            away.won += 1;
            away.points += 3;
            home.lost += 1;
        }
        else {
            home.draw += 1;
            away.draw += 1;
            home.points += 1;
            away.points += 1;
        }
    }
    const ranked = [...stats.entries()]
        .map(([teamId, s]) => ({
        teamId,
        ...s,
        goalDiff: s.goalsFor - s.goalsAgainst
    }))
        .sort((a, b) => b.points - a.points || b.goalDiff - a.goalDiff || b.goalsFor - a.goalsFor);
    for (let i = 0; i < ranked.length; i++) {
        const t = ranked[i];
        await pool.query(`UPDATE standings SET
        rank = $1, points = $2, played = $3, won = $4, draw = $5, lost = $6,
        goals_for = $7, goals_against = $8, goal_diff = $9
      WHERE group_id = $10 AND team_id = $11`, [
            i + 1,
            t.points,
            t.played,
            t.won,
            t.draw,
            t.lost,
            t.goalsFor,
            t.goalsAgainst,
            t.goalDiff,
            groupId,
            t.teamId
        ]);
    }
}
