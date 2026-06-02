import { TeamFlag } from "./TeamFlag";

interface TeamRow {
  team_name: string;
  rank: number;
  points?: number;
  played?: number;
  team_logo_url?: string | null;
}

interface GroupCardProps {
  groupName: string;
  teams: TeamRow[];
}

export function GroupCard({ groupName, teams }: GroupCardProps) {
  const sorted = [...teams].sort((a, b) => a.rank - b.rank);

  return (
    <article className="group-card">
      <div className="group-pill">{groupName}</div>
      <ul className="group-teams">
        {sorted.map((team) => (
          <li key={team.team_name} className="group-team-row">
            <span className="group-team-rank">{team.rank}</span>
            <TeamFlag name={team.team_name} logoUrl={team.team_logo_url} />
            <span className="team-name-upper">{team.team_name}</span>
            <span className="group-team-stats">
              {team.played !== undefined && (
                <span className="group-team-pj" title="Partidos jugados">
                  {team.played} PJ
                </span>
              )}
              {team.points !== undefined && <span className="team-pts">{team.points} pts</span>}
            </span>
          </li>
        ))}
      </ul>
    </article>
  );
}
