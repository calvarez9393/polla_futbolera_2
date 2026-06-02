import { pool } from "../../db/pool.js";
import { getActiveTournamentId } from "../settings/service.js";
import {
  groupQualificationFromStandings,
  resolveFifaQualifiers,
  type FifaQualifiersResult,
  type MatchScoreInput
} from "../standings/simulate.js";
import {
  computeOfficialQualifiersFromResults,
  getOfficialQualifiedTeams,
  OFFICIAL_QUALIFIERS_COUNT,
  setOfficialQualifiedTeams
} from "../scoring/qualifiers.js";
import { recalculateGroupStandings } from "../standings/recalculate.js";

export async function computeUserQualifiersFromPredictions(
  userId: number
): Promise<FifaQualifiersResult & { predictedMatches: number; expectedGroupMatches: number }> {
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) {
    return {
      groups: [],
      directQualifiers: [],
      bestThirds: [],
      allThirdsRanked: [],
      predictedMatches: 0,
      expectedGroupMatches: 0
    };
  }

  const groupsResult = await pool.query(
    `SELECT g.id, g.name FROM groups g WHERE g.tournament_id = $1 ORDER BY g.name`,
    [tournamentId]
  );

  const teamNames = new Map<number, string>();
  const groups: ReturnType<typeof groupQualificationFromStandings>[] = [];
  let predictedMatches = 0;
  let expectedGroupMatches = 0;

  for (const g of groupsResult.rows) {
    const groupId = g.id as number;
    const groupName = g.name as string;

    const teamsResult = await pool.query(
      `SELECT s.team_id, t.name FROM standings s
      JOIN teams t ON t.id = s.team_id
      WHERE s.group_id = $1 ORDER BY s.rank`,
      [groupId]
    );
    const teamIds = teamsResult.rows.map((r) => r.team_id as number);
    for (const r of teamsResult.rows) {
      teamNames.set(r.team_id as number, r.name as string);
    }

    const matchesResult = await pool.query(
      `SELECT m.id, m.home_team_id, m.away_team_id,
        p.predicted_home_score, p.predicted_away_score
      FROM matches m
      LEFT JOIN predictions p ON p.match_id = m.id AND p.user_id = $2
      WHERE m.group_id = $1 AND m.stage = 'GROUP'`,
      [groupId, userId]
    );

    expectedGroupMatches += matchesResult.rows.length;

    const matchInputs: MatchScoreInput[] = [];
    for (const row of matchesResult.rows) {
      if (row.predicted_home_score == null || row.predicted_away_score == null) continue;
      predictedMatches += 1;
      matchInputs.push({
        homeTeamId: row.home_team_id as number,
        awayTeamId: row.away_team_id as number,
        homeScore: row.predicted_home_score as number,
        awayScore: row.predicted_away_score as number
      });
    }

    groups.push(
      groupQualificationFromStandings(groupId, groupName, teamIds, matchInputs, teamNames)
    );
  }

  const fifa = resolveFifaQualifiers(groups, teamNames);
  return { ...fifa, predictedMatches, expectedGroupMatches };
}

export async function syncUserQualifierPredictions(userId: number): Promise<FifaQualifiersResult> {
  const result = await computeUserQualifiersFromPredictions(userId);

  await pool.query("DELETE FROM qualifier_predictions WHERE user_id = $1", [userId]);
  for (const teamId of result.directQualifiers) {
    await pool.query(
      "INSERT INTO qualifier_predictions (user_id, team_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
      [userId, teamId]
    );
  }

  return result;
}

export async function syncAllUsersQualifierPredictions(): Promise<{ users: number }> {
  const users = await pool.query("SELECT id FROM users WHERE role IN ('USER', 'ADMIN')");
  for (const { id } of users.rows) {
    await syncUserQualifierPredictions(id as number);
  }
  return { users: users.rows.length };
}

export { computeOfficialQualifiersFromResults } from "../scoring/qualifiers.js";

export async function syncOfficialQualifiersFromResults(): Promise<number[]> {
  const teamIds = await computeOfficialQualifiersFromResults();
  if (teamIds.length === OFFICIAL_QUALIFIERS_COUNT) {
    await setOfficialQualifiedTeams(teamIds);
  }
  return teamIds;
}

export async function enrichQualifiersForApi(
  userId: number,
  fifa: FifaQualifiersResult & { predictedMatches: number; expectedGroupMatches: number }
) {
  const tournamentId = await getActiveTournamentId();
  const teamsResult = tournamentId
    ? await pool.query(
        `SELECT t.id, t.name, t.short_name, t.logo_url, g.name AS group_name, g.id AS group_id
        FROM teams t
        JOIN standings s ON s.team_id = t.id AND s.tournament_id = $1
        JOIN groups g ON g.id = s.group_id`,
        [tournamentId]
      )
    : { rows: [] };

  const teamById = new Map(
    teamsResult.rows.map((r) => [
      r.id as number,
      {
        id: r.id as number,
        name: r.name as string,
        shortName: r.short_name as string,
        logoUrl: r.logo_url as string | null,
        groupName: r.group_name as string,
        groupId: r.group_id as number
      }
    ])
  );

  const official = await getOfficialQualifiedTeams();
  const officialSet = new Set(official);

  const score = await pool.query(
    `SELECT points, breakdown FROM prediction_scores
    WHERE user_id = $1 AND source_type = 'QUALIFIERS' AND source_id = 0`,
    [userId]
  );

  return {
    predictedMatches: fifa.predictedMatches,
    expectedGroupMatches: fifa.expectedGroupMatches,
    directQualifiers: fifa.directQualifiers,
    bestThirds: fifa.bestThirds.map((t) => ({
      ...t,
      team: teamById.get(t.teamId)
    })),
    allThirdsRanked: fifa.allThirdsRanked.map((t) => ({
      ...t,
      team: teamById.get(t.teamId),
      isBestThird: fifa.bestThirds.some((b) => b.teamId === t.teamId)
    })),
    groups: fifa.groups.map((g) => ({
      groupId: g.groupId,
      groupName: g.groupName,
      rows: g.standings.map((s, idx) => ({
        rank: idx + 1,
        teamId: s.teamId,
        team: teamById.get(s.teamId),
        points: s.points,
        goalDiff: s.goalDiff,
        goalsFor: s.goalsFor,
        played: s.played,
        qualifies: idx < 2,
        isThird: idx === 2,
        officialQualified: officialSet.has(s.teamId)
      }))
    })),
    earnedPoints: score.rows[0]?.points ?? null,
    earnedBreakdown: score.rows[0]?.breakdown ?? null,
    officialQualifiedCount: official.length
  };
}

export async function getOfficialStandingsByGroup(): Promise<
  Array<{
    groupId: number;
    groupName: string;
    teams: Array<{
      teamId: number;
      name: string;
      logoUrl: string | null;
      rank: number;
      points: number;
      played: number;
      goalDiff: number;
      goalsFor: number;
    }>;
  }>
> {
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) return [];

  const groups = await pool.query(
    `SELECT g.id, g.name FROM groups g WHERE g.tournament_id = $1 ORDER BY g.name`,
    [tournamentId]
  );

  const result = [];
  for (const g of groups.rows) {
    await recalculateGroupStandings(g.id as number);
    const teams = await pool.query(
      `SELECT s.rank, s.points, s.played, s.goal_diff, s.goals_for, s.team_id, t.name, t.logo_url
      FROM standings s JOIN teams t ON t.id = s.team_id
      WHERE s.group_id = $1 ORDER BY s.rank`,
      [g.id]
    );
    result.push({
      groupId: g.id as number,
      groupName: g.name as string,
      teams: teams.rows.map((r) => ({
        teamId: r.team_id as number,
        name: r.name as string,
        logoUrl: r.logo_url as string | null,
        rank: r.rank as number,
        points: r.points as number,
        played: r.played as number,
        goalDiff: r.goal_diff as number,
        goalsFor: r.goals_for as number
      }))
    });
  }
  return result;
}
