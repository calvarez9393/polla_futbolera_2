export interface TeamStandingRow {
  teamId: number;
  played: number;
  won: number;
  draw: number;
  lost: number;
  goalsFor: number;
  goalsAgainst: number;
  goalDiff: number;
  points: number;
}

export interface MatchScoreInput {
  homeTeamId: number;
  awayTeamId: number;
  homeScore: number;
  awayScore: number;
}

/** Tabla de grupo a partir de marcadores (oficiales o predichos). */
export function buildGroupStandings(
  teamIds: number[],
  matches: MatchScoreInput[]
): TeamStandingRow[] {
  const stats = new Map<number, TeamStandingRow>();
  for (const id of teamIds) {
    stats.set(id, {
      teamId: id,
      played: 0,
      won: 0,
      draw: 0,
      lost: 0,
      goalsFor: 0,
      goalsAgainst: 0,
      goalDiff: 0,
      points: 0
    });
  }

  for (const m of matches) {
    const home = stats.get(m.homeTeamId);
    const away = stats.get(m.awayTeamId);
    if (!home || !away) continue;

    home.played += 1;
    away.played += 1;
    home.goalsFor += m.homeScore;
    home.goalsAgainst += m.awayScore;
    away.goalsFor += m.awayScore;
    away.goalsAgainst += m.homeScore;

    if (m.homeScore > m.awayScore) {
      home.won += 1;
      home.points += 3;
      away.lost += 1;
    } else if (m.homeScore < m.awayScore) {
      away.won += 1;
      away.points += 3;
      home.lost += 1;
    } else {
      home.draw += 1;
      away.draw += 1;
      home.points += 1;
      away.points += 1;
    }
  }

  return [...stats.values()].map((s) => ({
    ...s,
    goalDiff: s.goalsFor - s.goalsAgainst
  }));
}

/** Criterios FIFA simplificados: puntos, dif. goles, goles a favor, nombre (sorteo). */
export function rankStandings(rows: TeamStandingRow[], teamNames?: Map<number, string>): TeamStandingRow[] {
  return [...rows].sort((a, b) => {
    if (b.points !== a.points) return b.points - a.points;
    if (b.goalDiff !== a.goalDiff) return b.goalDiff - a.goalDiff;
    if (b.goalsFor !== a.goalsFor) return b.goalsFor - a.goalsFor;
    const nameA = teamNames?.get(a.teamId) ?? "";
    const nameB = teamNames?.get(b.teamId) ?? "";
    return nameA.localeCompare(nameB, "es");
  });
}

export interface GroupQualificationResult {
  groupId: number;
  groupName: string;
  standings: TeamStandingRow[];
  first: number | null;
  second: number | null;
  third: number | null;
  fourth: number | null;
}

export interface FifaQualifiersResult {
  groups: GroupQualificationResult[];
  directQualifiers: number[];
  bestThirds: Array<{
    teamId: number;
    groupId: number;
    groupName: string;
    points: number;
    goalDiff: number;
    goalsFor: number;
    played: number;
  }>;
  allThirdsRanked: Array<{
    teamId: number;
    groupId: number;
    groupName: string;
    points: number;
    goalDiff: number;
    goalsFor: number;
    played: number;
  }>;
}

const BEST_THIRDS_COUNT = 8;

export function resolveFifaQualifiers(
  groups: GroupQualificationResult[],
  teamNames: Map<number, string>
): FifaQualifiersResult {
  const directQualifiers: number[] = [];
  const allThirdsRanked: FifaQualifiersResult["allThirdsRanked"] = [];

  for (const g of groups) {
    if (g.first) directQualifiers.push(g.first);
    if (g.second) directQualifiers.push(g.second);
    if (g.third) {
      const thirdRow = g.standings.find((s) => s.teamId === g.third);
      if (thirdRow) {
        allThirdsRanked.push({
          teamId: g.third,
          groupId: g.groupId,
          groupName: g.groupName,
          points: thirdRow.points,
          goalDiff: thirdRow.goalDiff,
          goalsFor: thirdRow.goalsFor,
          played: thirdRow.played
        });
      }
    }
  }

  allThirdsRanked.sort((a, b) => {
    if (b.points !== a.points) return b.points - a.points;
    if (b.goalDiff !== a.goalDiff) return b.goalDiff - a.goalDiff;
    if (b.goalsFor !== a.goalsFor) return b.goalsFor - a.goalsFor;
    if (b.played !== a.played) return b.played - a.played;
    return (teamNames.get(a.teamId) ?? "").localeCompare(teamNames.get(b.teamId) ?? "", "es");
  });

  const bestThirds = allThirdsRanked.slice(0, BEST_THIRDS_COUNT);

  return { groups, directQualifiers, bestThirds, allThirdsRanked };
}

export function groupQualificationFromStandings(
  groupId: number,
  groupName: string,
  teamIds: number[],
  matches: MatchScoreInput[],
  teamNames: Map<number, string>
): GroupQualificationResult {
  const standings = rankStandings(buildGroupStandings(teamIds, matches), teamNames);
  return {
    groupId,
    groupName,
    standings,
    first: standings[0]?.teamId ?? null,
    second: standings[1]?.teamId ?? null,
    third: standings[2]?.teamId ?? null,
    fourth: standings[3]?.teamId ?? null
  };
}
