import { predictedMatchupFromRow, officialMatchupFromRow, type PredictedMatchupDto } from "../bracket/resolveUserSlotTeams.js";

export function mapCalendarMatchRow(
  row: Record<string, unknown>,
  availability: Record<string, unknown>,
  lockAt: Date
): Record<string, unknown> {
  const predictedMatchup: PredictedMatchupDto | null = predictedMatchupFromRow({
    stage: row.stage as string,
    predicted_home_score: row.predicted_home_score as number | null,
    bracket_home_team_id: row.bracket_home_team_id as number | null,
    bracket_away_team_id: row.bracket_away_team_id as number | null,
    bracket_home_team_name: row.bracket_home_team_name as string | null,
    bracket_away_team_name: row.bracket_away_team_name as string | null,
    bracket_home_team_logo_url: row.bracket_home_team_logo_url as string | null,
    bracket_away_team_logo_url: row.bracket_away_team_logo_url as string | null,
    home_team_id: row.home_team_id as number,
    away_team_id: row.away_team_id as number,
    home_team_name: row.home_team_name as string,
    away_team_name: row.away_team_name as string,
    home_team_logo_url: row.home_team_logo_url as string | null,
    away_team_logo_url: row.away_team_logo_url as string | null
  });

  const officialMatchup: PredictedMatchupDto | null = officialMatchupFromRow({
    official_home_team_id: row.official_home_team_id as number | null,
    official_away_team_id: row.official_away_team_id as number | null,
    official_home_team_name: row.official_home_team_name as string | null,
    official_away_team_name: row.official_away_team_name as string | null,
    official_home_team_logo_url: row.official_home_team_logo_url as string | null,
    official_away_team_logo_url: row.official_away_team_logo_url as string | null,
    home_team_id: row.home_team_id as number,
    away_team_id: row.away_team_id as number,
    home_team_name: row.home_team_name as string,
    away_team_name: row.away_team_name as string,
    home_team_logo_url: row.home_team_logo_url as string | null,
    away_team_logo_url: row.away_team_logo_url as string | null
  });

  return {
    id: row.id,
    stage: row.stage,
    roundKey: row.round_key,
    status: row.status,
    startsAt: row.starts_at,
    kickoffTimeLocal: row.kickoff_time_local,
    roundLabel: row.round_label,
    matchday: row.matchday,
    groupName: row.group_name,
    homeTeamId: Number(row.home_team_id),
    homeTeamName: row.home_team_name,
    homeTeamLogoUrl: row.home_team_logo_url,
    awayTeamId: Number(row.away_team_id),
    awayTeamName: row.away_team_name,
    awayTeamLogoUrl: row.away_team_logo_url,
    homeScore: row.home_score,
    awayScore: row.away_score,
    winnerTeamId: row.winner_team_id ? Number(row.winner_team_id) : null,
    ...availability,
    predictionLockAt: lockAt.toISOString(),
    prediction:
      row.predicted_home_score != null
        ? {
            predictedHomeScore: row.predicted_home_score,
            predictedAwayScore: row.predicted_away_score,
            predictedAdvancingTeamId: row.predicted_advancing_team_id
              ? Number(row.predicted_advancing_team_id)
              : null
          }
        : null,
    predictedMatchup,
    officialMatchup,
    advancingTeamId: row.advancingTeamId ? Number(row.advancingTeamId) : null,
    advancingTeamName: (row.advancingTeamName as string) ?? null,
    advancingTeamLogoUrl: (row.advancingTeamLogoUrl as string | null) ?? null,
    advancingViaPenalties: Boolean(row.advancingViaPenalties),
    officialAdvancingTeamId: row.officialAdvancingTeamId
      ? Number(row.officialAdvancingTeamId)
      : null,
    officialAdvancingTeamName: (row.officialAdvancingTeamName as string) ?? null,
    officialAdvancingTeamLogoUrl: (row.officialAdvancingTeamLogoUrl as string | null) ?? null,
    officialAdvancingViaPenalties: Boolean(row.officialAdvancingViaPenalties),
    nextRoundLabel: (row.nextRoundLabel as string) ?? null,
    earnedPoints: row.earned_points ?? null,
    earnedBreakdown: row.earned_breakdown ?? null
  };
}
