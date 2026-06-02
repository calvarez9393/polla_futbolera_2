import { pool } from "../../db/pool.js";
import { env } from "../../config/env.js";
import { footballApi, withApiRetry } from "../footballApi/client.js";
import { toFootballApiError } from "../footballApi/errors.js";
import { assertApiFootballOk } from "../footballApi/validate.js";
import { calculateMatchScores } from "../scoring/service.js";
function mapFixtureStatus(short) {
    if (!short)
        return "NOT_STARTED";
    if (["FT", "AET", "PEN"].includes(short))
        return "FINISHED";
    if (["1H", "2H", "HT", "ET", "BT", "P"].includes(short))
        return "LIVE";
    return "NOT_STARTED";
}
export async function runSync(source = "cron") {
    const run = await pool.query("INSERT INTO sync_runs (status, details) VALUES ('RUNNING', $1::jsonb) RETURNING id", [
        JSON.stringify({ source })
    ]);
    const runId = run.rows[0].id;
    try {
        const [teamsRes, fixturesRes, standingsRes] = await Promise.all([
            withApiRetry(() => footballApi.get("/teams", { params: { league: env.API_FOOTBALL_LEAGUE_ID, season: env.API_FOOTBALL_SEASON } })),
            withApiRetry(() => footballApi.get("/fixtures", { params: { league: env.API_FOOTBALL_LEAGUE_ID, season: env.API_FOOTBALL_SEASON } })),
            withApiRetry(() => footballApi.get("/standings", { params: { league: env.API_FOOTBALL_LEAGUE_ID, season: env.API_FOOTBALL_SEASON } }))
        ]);
        assertApiFootballOk(teamsRes.data, "teams");
        assertApiFootballOk(fixturesRes.data, "fixtures");
        assertApiFootballOk(standingsRes.data, "standings");
        const fixtureCount = fixturesRes.data.response?.length ?? 0;
        if (fixtureCount === 0) {
            throw new Error(`No se recibieron partidos para liga ${env.API_FOOTBALL_LEAGUE_ID} temporada ${env.API_FOOTBALL_SEASON}. En plan gratuito usa temporada 2022–2024.`);
        }
        await pool.query(`INSERT INTO tournaments (external_id, name, season)
      VALUES ($1, $2, $3)
      ON CONFLICT (external_id) DO UPDATE SET name = EXCLUDED.name, season = EXCLUDED.season`, [env.API_FOOTBALL_LEAGUE_ID, `League ${env.API_FOOTBALL_LEAGUE_ID}`, env.API_FOOTBALL_SEASON]);
        const tournament = (await pool.query("SELECT id FROM tournaments WHERE external_id = $1", [env.API_FOOTBALL_LEAGUE_ID])).rows[0];
        for (const item of teamsRes.data.response ?? []) {
            const team = item.team;
            await pool.query(`INSERT INTO teams (external_id, name, short_name, logo_url)
        VALUES ($1, $2, $3, $4)
        ON CONFLICT (external_id) DO UPDATE
        SET name = EXCLUDED.name, short_name = EXCLUDED.short_name, logo_url = EXCLUDED.logo_url`, [String(team.id), team.name, team.code ?? null, team.logo ?? null]);
        }
        for (const fixtureItem of fixturesRes.data.response ?? []) {
            const fixture = fixtureItem.fixture;
            const teams = fixtureItem.teams;
            const goals = fixtureItem.goals;
            const league = fixtureItem.league;
            const home = (await pool.query("SELECT id FROM teams WHERE external_id = $1", [String(teams.home.id)])).rows[0];
            const away = (await pool.query("SELECT id FROM teams WHERE external_id = $1", [String(teams.away.id)])).rows[0];
            if (!home || !away)
                continue;
            let groupId = null;
            const groupName = typeof league.round === "string" && league.round.includes("Group") ? league.round : null;
            if (groupName) {
                const group = await pool.query(`INSERT INTO groups (tournament_id, name, external_id)
          VALUES ($1, $2, $3)
          ON CONFLICT (external_id) DO UPDATE SET name = EXCLUDED.name
          RETURNING id`, [tournament.id, groupName, groupName]);
                groupId = group.rows[0].id;
            }
            const status = mapFixtureStatus(fixture.status?.short);
            const stage = groupId ? "GROUP" : "KNOCKOUT";
            const winnerExternal = teams.home.winner ? String(teams.home.id) : teams.away.winner ? String(teams.away.id) : null;
            const winner = winnerExternal ? (await pool.query("SELECT id FROM teams WHERE external_id = $1", [winnerExternal])).rows[0] : null;
            await pool.query(`INSERT INTO matches
          (external_id, tournament_id, group_id, stage, status, starts_at, home_team_id, away_team_id, home_score, away_score, winner_team_id, updated_at)
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,NOW())
        ON CONFLICT (external_id) DO UPDATE SET
          group_id = EXCLUDED.group_id,
          stage = EXCLUDED.stage,
          status = EXCLUDED.status,
          starts_at = EXCLUDED.starts_at,
          home_score = EXCLUDED.home_score,
          away_score = EXCLUDED.away_score,
          winner_team_id = EXCLUDED.winner_team_id,
          updated_at = NOW()`, [
                String(fixture.id),
                tournament.id,
                groupId,
                stage,
                status,
                fixture.date,
                home.id,
                away.id,
                goals.home ?? null,
                goals.away ?? null,
                winner?.id ?? null
            ]);
        }
        await pool.query("DELETE FROM standings");
        for (const standingsGroup of standingsRes.data.response?.[0]?.league?.standings ?? []) {
            for (const row of standingsGroup) {
                const team = (await pool.query("SELECT id FROM teams WHERE external_id = $1", [String(row.team.id)])).rows[0];
                if (!team)
                    continue;
                const group = await pool.query(`INSERT INTO groups (tournament_id, name, external_id)
          VALUES ($1, $2, $3)
          ON CONFLICT (external_id) DO UPDATE SET name = EXCLUDED.name
          RETURNING id`, [tournament.id, row.group, row.group]);
                await pool.query(`INSERT INTO standings
            (tournament_id, group_id, team_id, rank, points, played, won, draw, lost, goals_for, goals_against, goal_diff)
          VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)`, [
                    tournament.id,
                    group.rows[0].id,
                    team.id,
                    row.rank,
                    row.points,
                    row.all.played,
                    row.all.win,
                    row.all.draw,
                    row.all.lose,
                    row.all.goals.for,
                    row.all.goals.against,
                    row.goalsDiff
                ]);
            }
        }
        const finished = await pool.query("SELECT id FROM matches WHERE status = 'FINISHED'");
        for (const match of finished.rows) {
            await calculateMatchScores(match.id);
        }
        await pool.query("UPDATE sync_runs SET status = 'SUCCESS', finished_at = NOW(), details = details || $2::jsonb WHERE id = $1", [
            runId,
            JSON.stringify({
                teams: teamsRes.data.response?.length ?? 0,
                fixtures: fixtureCount,
                standingsGroups: standingsRes.data.response?.[0]?.league?.standings?.length ?? 0
            })
        ]);
    }
    catch (error) {
        await pool.query("UPDATE sync_runs SET status = 'FAILED', finished_at = NOW(), details = details || $2::jsonb WHERE id = $1", [
            runId,
            JSON.stringify({
                error: error instanceof Error ? error.message : "unknown",
                hint: "Manteniendo datos locales previos por tolerancia a fallos"
            })
        ]);
        throw toFootballApiError(error);
    }
}
