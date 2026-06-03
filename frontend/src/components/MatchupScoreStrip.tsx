import { TeamFlag } from "./TeamFlag";

export interface MatchupTeams {
  homeTeamName: string;
  homeTeamLogoUrl?: string | null;
  awayTeamName: string;
  awayTeamLogoUrl?: string | null;
}

export function matchupToTeams(matchup: MatchupTeams & { homeTeamId?: number; awayTeamId?: number }): MatchupTeams {
  return {
    homeTeamName: matchup.homeTeamName,
    homeTeamLogoUrl: matchup.homeTeamLogoUrl,
    awayTeamName: matchup.awayTeamName,
    awayTeamLogoUrl: matchup.awayTeamLogoUrl
  };
}

interface MatchupScoreStripProps {
  teams: MatchupTeams;
  homeScore: number | string | null;
  awayScore: number | string | null;
  label?: string;
  variant?: "default" | "compact" | "prediction";
  className?: string;
}

export function MatchupScoreStrip({
  teams,
  homeScore,
  awayScore,
  label,
  variant = "default",
  className = ""
}: MatchupScoreStripProps) {
  const scoreHome = homeScore ?? "–";
  const scoreAway = awayScore ?? "–";

  return (
    <div
      className={`matchup-score-strip matchup-score-strip--${variant}${className ? ` ${className}` : ""}`}
    >
      {label && <span className="matchup-score-strip-label">{label}</span>}
      <div className="matchup-score-strip-grid">
        <div className="match-team home">
          <span className="match-team-name">{teams.homeTeamName}</span>
          <TeamFlag name={teams.homeTeamName} logoUrl={teams.homeTeamLogoUrl} size="lg" />
        </div>
        <div className="match-score">
          {scoreHome} : {scoreAway}
        </div>
        <div className="match-team away">
          <TeamFlag name={teams.awayTeamName} logoUrl={teams.awayTeamLogoUrl} size="lg" />
          <span className="match-team-name">{teams.awayTeamName}</span>
        </div>
      </div>
    </div>
  );
}
