import { TeamFlag } from "./TeamFlag";
import { KnockoutAdvancingBanner } from "./KnockoutAdvancingBanner";

export interface R16BracketTeam {
  teamId: number;
  name: string;
  shortName?: string | null;
  logoUrl?: string | null;
  groupName?: string | null;
}

export interface R16BracketMatchRow {
  matchId: number;
  matchNumber: number;
  externalNum: number;
  label: string;
  homeSlotLabel: string;
  awaySlotLabel: string;
  home: R16BracketTeam | null;
  away: R16BracketTeam | null;
  advancingTeam?: R16BracketTeam | null;
  advancingViaPenalties?: boolean;
  nextRoundLabel?: string;
  isOfficial?: boolean;
  dateLocal?: string;
  city?: string;
  octavosMatchNum?: number;
  octavosLabel?: string;
  cuartosMatchNum?: number | null;
}

interface R16BracketGridProps {
  matches: R16BracketMatchRow[];
  emptyHint?: string;
  compact?: boolean;
}

function TeamCell({ team, slotLabel }: { team: R16BracketTeam | null; slotLabel: string }) {
  if (team) {
    return (
      <div className="r16-bracket-team">
        <TeamFlag name={team.name} logoUrl={team.logoUrl} size="sm" />
        <span className="r16-bracket-team-name">{team.name}</span>
        {team.groupName && <span className="r16-bracket-team-group">Gr. {team.groupName}</span>}
      </div>
    );
  }
  return (
    <div className="r16-bracket-team r16-bracket-team--empty">
      <span className="r16-bracket-slot">{slotLabel}</span>
    </div>
  );
}

export function R16BracketGrid({ matches, emptyHint, compact }: R16BracketGridProps) {
  if (matches.length === 0) {
    return (
      <div className="panel-card empty-state">
        <strong>Sin cuadro de dieciseisavos</strong>
        {emptyHint && <p style={{ marginTop: "0.5rem" }}>{emptyHint}</p>}
      </div>
    );
  }

  const sorted = [...matches].sort((a, b) => a.externalNum - b.externalNum);

  return (
    <div className={`r16-bracket-grid${compact ? " r16-bracket-grid--compact" : ""}`} role="list">
      {sorted.map((m) => (
        <article
          key={m.externalNum}
          className={`r16-bracket-match${m.isOfficial ? " r16-bracket-match--official" : ""}`}
          role="listitem"
        >
          <header className="r16-bracket-match-header">
            <span className="r16-bracket-match-num">P{m.externalNum}</span>
            <span className="r16-bracket-match-label">{m.homeSlotLabel} vs {m.awaySlotLabel}</span>
          </header>
          {m.octavosMatchNum != null && (
            <p className="r16-bracket-octavos-hint">
              Octavos → Partido {m.octavosMatchNum}
              {m.cuartosMatchNum != null && ` · Cuartos P${m.cuartosMatchNum}`}
            </p>
          )}
          <div className="r16-bracket-pairing">
            <TeamCell team={m.home} slotLabel={m.homeSlotLabel} />
            <span className="r16-bracket-vs">vs</span>
            <TeamCell team={m.away} slotLabel={m.awaySlotLabel} />
          </div>
          {m.advancingTeam && (
            <KnockoutAdvancingBanner
              teamName={m.advancingTeam.name}
              logoUrl={m.advancingTeam.logoUrl}
              nextRoundLabel={m.nextRoundLabel ?? "octavos de final"}
              viaPenalties={m.advancingViaPenalties}
              compact
            />
          )}
          {m.city && (
            <p className="r16-bracket-meta">
              {m.dateLocal &&
                new Date(`${m.dateLocal}T12:00:00`).toLocaleDateString("es-ES", {
                  day: "numeric",
                  month: "short"
                })}{" "}
              · {m.city}
            </p>
          )}
        </article>
      ))}
    </div>
  );
}
