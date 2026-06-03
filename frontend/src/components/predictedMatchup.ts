export interface PredictedMatchup {
  homeTeamId: number;
  homeTeamName: string;
  homeTeamLogoUrl?: string | null;
  awayTeamId: number;
  awayTeamName: string;
  awayTeamLogoUrl?: string | null;
}

export function sameMatchup(
  a: { homeTeamId: number; awayTeamId: number },
  b: { homeTeamId: number; awayTeamId: number }
): boolean {
  return (
    (a.homeTeamId === b.homeTeamId && a.awayTeamId === b.awayTeamId) ||
    (a.homeTeamId === b.awayTeamId && a.awayTeamId === b.homeTeamId)
  );
}
