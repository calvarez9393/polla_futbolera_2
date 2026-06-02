import { pool } from "../../db/pool.js";
import { setSetting } from "../settings/service.js";
import {
  WC2026_GROUPS,
  WC2026_GROUP_FIXTURES,
  fixtureKickoffUtc,
  type Wc2026GroupLetter
} from "./worldCup2026Fixtures.js";
import { flagUrlForTeam } from "./teamFlags.js";

function teamSlug(name: string): string {
  return name
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

function shortName(name: string): string {
  const map: Record<string, string> = {
    México: "MEX",
    "Estados Unidos": "USA",
    Canadá: "CAN",
    "Corea del Sur": "KOR",
    "República Checa": "CZE",
    "Bosnia y Herzegovina": "BIH",
    "Costa de Marfil": "CIV",
    "Países Bajos": "NED",
    "Arabia Saudita": "KSA",
    "Nueva Zelanda": "NZL",
    "RD Congo": "COD",
    Uzbekistán: "UZB",
    Inglaterra: "ENG"
  };
  return map[name] ?? name.slice(0, 3).toUpperCase();
}

/** Elimina datos del Mundial 2026 (y partidos placeholder wc2026-*) */
export async function clearWorldCup2026Data(): Promise<void> {
  const tournament = await pool.query("SELECT id FROM tournaments WHERE external_id = 'wc-2026'");

  if (tournament.rows[0]) {
    const tournamentId = tournament.rows[0].id as number;
    await pool.query(
      `DELETE FROM prediction_scores WHERE source_type = 'MATCH' AND source_id IN (
        SELECT id FROM matches WHERE tournament_id = $1
      )`,
      [tournamentId]
    );
    await pool.query("DELETE FROM predictions WHERE match_id IN (SELECT id FROM matches WHERE tournament_id = $1)", [
      tournamentId
    ]);
    await pool.query("DELETE FROM matches WHERE tournament_id = $1", [tournamentId]);
    await pool.query("DELETE FROM standings WHERE tournament_id = $1", [tournamentId]);
    await pool.query("DELETE FROM groups WHERE tournament_id = $1", [tournamentId]);
  }

  await pool.query(
    `DELETE FROM prediction_scores WHERE source_type = 'MATCH' AND source_id IN (
      SELECT id FROM matches WHERE external_id LIKE 'wc2026-%'
    )`
  );
  await pool.query("DELETE FROM predictions WHERE match_id IN (SELECT id FROM matches WHERE external_id LIKE 'wc2026-%')");
  await pool.query("DELETE FROM matches WHERE external_id LIKE 'wc2026-%'");
  await pool.query("DELETE FROM teams WHERE external_id LIKE 'wc2026-%'");
}

export async function importWorldCup2026Schedule(): Promise<{
  teams: number;
  groups: number;
  matches: number;
}> {
  await clearWorldCup2026Data();

  await setSetting("tournament_name", "Mundial FIFA 2026");
  await setSetting("tournament_season", "2026");
  await setSetting("data_source", "manual");

  const tournament = await pool.query(
    `INSERT INTO tournaments (external_id, name, season)
    VALUES ('wc-2026', 'Mundial FIFA 2026', '2026')
    ON CONFLICT (external_id) DO UPDATE SET name = EXCLUDED.name, season = EXCLUDED.season
    RETURNING id`
  );
  const tournamentId = tournament.rows[0].id as number;

  const teamIdByName = new Map<string, number>();
  let teamCount = 0;

  for (const letter of Object.keys(WC2026_GROUPS) as Wc2026GroupLetter[]) {
    for (const name of WC2026_GROUPS[letter]) {
      const externalId = `wc2026-team-${teamSlug(name)}`;
      const logoUrl = flagUrlForTeam(name);
      const team = await pool.query(
        `INSERT INTO teams (external_id, name, short_name, logo_url)
        VALUES ($1, $2, $3, $4)
        ON CONFLICT (external_id) DO UPDATE SET
          name = EXCLUDED.name,
          short_name = EXCLUDED.short_name,
          logo_url = EXCLUDED.logo_url
        RETURNING id`,
        [externalId, name, shortName(name), logoUrl]
      );
      teamIdByName.set(name, team.rows[0].id as number);
      teamCount += 1;
    }
  }

  const groupIdByLetter = new Map<Wc2026GroupLetter, number>();

  for (const letter of Object.keys(WC2026_GROUPS) as Wc2026GroupLetter[]) {
    const group = await pool.query(
      `INSERT INTO groups (tournament_id, name, external_id)
      VALUES ($1, $2, $3)
      ON CONFLICT (external_id) DO UPDATE SET name = EXCLUDED.name, tournament_id = EXCLUDED.tournament_id
      RETURNING id`,
      [tournamentId, `Grupo ${letter}`, `GROUP_${letter}`]
    );
    const groupId = group.rows[0].id as number;
    groupIdByLetter.set(letter, groupId);

    const teams = WC2026_GROUPS[letter];
    for (let rank = 0; rank < teams.length; rank++) {
      const teamId = teamIdByName.get(teams[rank])!;
      await pool.query(
        `INSERT INTO standings
          (tournament_id, group_id, team_id, rank, points, played, won, draw, lost, goals_for, goals_against, goal_diff)
        VALUES ($1, $2, $3, $4, 0, 0, 0, 0, 0, 0, 0, 0)
        ON CONFLICT (group_id, team_id) DO UPDATE SET
          tournament_id = EXCLUDED.tournament_id,
          rank = EXCLUDED.rank`,
        [tournamentId, groupId, teamId, rank + 1]
      );
    }
  }

  let matchCount = 0;

  for (const fixture of WC2026_GROUP_FIXTURES) {
    const homeId = teamIdByName.get(fixture.home);
    const awayId = teamIdByName.get(fixture.away);
    if (!homeId || !awayId) {
      throw new Error(`Equipo no encontrado: ${fixture.home} vs ${fixture.away}`);
    }

    const startsAt = fixtureKickoffUtc(fixture);
    const groupId = groupIdByLetter.get(fixture.group)!;
    const roundLabel = `Fase de grupos · J${fixture.matchday} · ${fixture.venue}`;

    await pool.query(
      `INSERT INTO matches
        (external_id, tournament_id, group_id, stage, round_key, status, starts_at, calendar_date,
         kickoff_time_local, round_label, matchday, home_team_id, away_team_id)
      VALUES ($1,$2,$3,'GROUP','GROUP','NOT_STARTED',$4,$5,$6,$7,$8,$9,$10)
      ON CONFLICT (external_id) DO UPDATE SET
        starts_at = EXCLUDED.starts_at,
        calendar_date = EXCLUDED.calendar_date,
        kickoff_time_local = EXCLUDED.kickoff_time_local,
        round_label = EXCLUDED.round_label,
        matchday = EXCLUDED.matchday,
        home_team_id = EXCLUDED.home_team_id,
        away_team_id = EXCLUDED.away_team_id,
        group_id = EXCLUDED.group_id,
        updated_at = NOW()`,
      [
        `wc2026-match-${String(fixture.num).padStart(3, "0")}`,
        tournamentId,
        groupId,
        startsAt,
        fixture.dateLocal,
        fixture.timeLocal,
        roundLabel,
        fixture.matchday,
        homeId,
        awayId
      ]
    );
    matchCount += 1;
  }

  return { teams: teamCount, groups: Object.keys(WC2026_GROUPS).length, matches: matchCount };
}
