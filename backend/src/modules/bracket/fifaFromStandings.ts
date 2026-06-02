import { pool } from "../../db/pool.js";
import { getActiveTournamentId } from "../settings/service.js";
import { recalculateGroupStandings } from "../standings/recalculate.js";
import {
  groupQualificationFromStandings,
  resolveFifaQualifiers,
  type FifaQualifiersResult,
  type GroupQualificationResult,
  type MatchScoreInput
} from "../standings/simulate.js";

/** Tablas oficiales desde partidos GROUP finalizados (vía standings en BD). */
export async function computeOfficialFifaFromResults(): Promise<
  FifaQualifiersResult & { finishedGroupMatches: number; groupsWithFullTable: number }
> {
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

  const groupsResult = await pool.query(
    `SELECT g.id, g.name FROM groups g WHERE g.tournament_id = $1 ORDER BY g.name`,
    [tournamentId]
  );

  const teamNames = new Map<number, string>();
  const groups: GroupQualificationResult[] = [];
  let finishedGroupMatches = 0;
  let groupsWithFullTable = 0;

  for (const g of groupsResult.rows) {
    const groupId = g.id as number;
    const groupName = g.name as string;

    await recalculateGroupStandings(groupId);

    const teamsResult = await pool.query(
      `SELECT s.team_id, s.rank, s.points, s.played, s.won, s.draw, s.lost,
        s.goals_for, s.goals_against, s.goal_diff, t.name
      FROM standings s
      JOIN teams t ON t.id = s.team_id
      WHERE s.group_id = $1
      ORDER BY s.rank`,
      [groupId]
    );

    const teamIds = teamsResult.rows.map((r) => r.team_id as number);
    for (const r of teamsResult.rows) {
      teamNames.set(r.team_id as number, r.name as string);
    }

    const matchesResult = await pool.query(
      `SELECT home_team_id, away_team_id, home_score, away_score
      FROM matches
      WHERE group_id = $1 AND stage = 'GROUP' AND status = 'FINISHED'
        AND home_score IS NOT NULL AND away_score IS NOT NULL`,
      [groupId]
    );

    finishedGroupMatches += matchesResult.rows.length;
    const expectedPerGroup = await pool.query(
      `SELECT COUNT(*)::int AS c FROM matches WHERE group_id = $1 AND stage = 'GROUP'`,
      [groupId]
    );
    const expected = expectedPerGroup.rows[0]?.c as number;
    if (expected > 0 && matchesResult.rows.length >= expected) {
      groupsWithFullTable += 1;
    }

    const matchInputs: MatchScoreInput[] = matchesResult.rows.map((row) => ({
      homeTeamId: row.home_team_id as number,
      awayTeamId: row.away_team_id as number,
      homeScore: row.home_score as number,
      awayScore: row.away_score as number
    }));

    const simulated = groupQualificationFromStandings(
      groupId,
      groupName,
      teamIds,
      matchInputs,
      teamNames
    );

    // Preferir posiciones ya guardadas en standings (tras recalculate)
    const byRank = teamsResult.rows;
    groups.push({
      ...simulated,
      first: (byRank[0]?.team_id as number) ?? simulated.first,
      second: (byRank[1]?.team_id as number) ?? simulated.second,
      third: (byRank[2]?.team_id as number) ?? simulated.third,
      fourth: (byRank[3]?.team_id as number) ?? simulated.fourth
    });
  }

  const fifa = resolveFifaQualifiers(groups, teamNames);
  return { ...fifa, finishedGroupMatches, groupsWithFullTable };
}
