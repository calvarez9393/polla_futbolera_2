import { TeamFlag } from "./TeamFlag";
import { KnockoutAdvancingBanner } from "./KnockoutAdvancingBanner";
import type { R16BracketMatchRow } from "./R16BracketGrid";
import { WC2026_BRACKET_PAIRS, type BracketTreePair } from "../lib/wc2026BracketTree";

export interface BracketTreeMatch extends R16BracketMatchRow {
  externalNum: number;
  dateLocal?: string;
  city?: string;
  octavosMatchNum?: number;
  octavosLabel?: string;
  cuartosMatchNum?: number | null;
}

interface BracketTreeViewProps {
  matches: BracketTreeMatch[];
  tree?: { pairs: BracketTreePair[] };
}

function matchByNum(matches: BracketTreeMatch[], num: number): BracketTreeMatch | undefined {
  return matches.find((m) => m.externalNum === num);
}

function SlotRow({
  match,
  slot
}: {
  match: BracketTreeMatch;
  slot: "home" | "away";
}) {
  const team = slot === "home" ? match.home : match.away;
  const label = slot === "home" ? match.homeSlotLabel : match.awaySlotLabel;
  return (
    <div className={`bracket-slot${team ? "" : " bracket-slot--tbd"}`}>
      {team ? (
        <>
          <TeamFlag name={team.name} logoUrl={team.logoUrl} size="sm" />
          <span className="bracket-slot-name">{team.name}</span>
        </>
      ) : (
        <span className="bracket-slot-placeholder">{label}</span>
      )}
    </div>
  );
}

function R32Card({ match }: { match: BracketTreeMatch }) {
  return (
    <div className={`bracket-r32-card${match.isOfficial ? " bracket-r32-card--official" : ""}`}>
      <div className="bracket-r32-head">
        <span className="bracket-r32-num">P{match.externalNum}</span>
        <span className="bracket-r32-date">
          {match.dateLocal
            ? new Date(`${match.dateLocal}T12:00:00`).toLocaleDateString("es-ES", {
                weekday: "short",
                day: "numeric",
                month: "short"
              })
            : ""}
        </span>
      </div>
      <SlotRow match={match} slot="home" />
      <SlotRow match={match} slot="away" />
      {match.advancingTeam && (
        <KnockoutAdvancingBanner
          teamName={match.advancingTeam.name}
          logoUrl={match.advancingTeam.logoUrl}
          nextRoundLabel={match.nextRoundLabel ?? "octavos de final"}
          viaPenalties={match.advancingViaPenalties}
          compact
        />
      )}
      {match.city && <span className="bracket-r32-city">{match.city}</span>}
    </div>
  );
}

function BracketHalf({
  side,
  pairs,
  matches
}: {
  side: "left" | "right";
  pairs: BracketTreePair[];
  matches: BracketTreeMatch[];
}) {
  const sidePairs = pairs.filter((p) => p.side === side);

  return (
    <div className={`bracket-half bracket-half--${side}`}>
      {sidePairs.map((pair) => {
        const mA = matchByNum(matches, pair.r32Nums[0]);
        const mB = matchByNum(matches, pair.r32Nums[1]);
        if (!mA || !mB) return null;
        const cuartos = WC2026_BRACKET_PAIRS.find((p) => p.r16Num === pair.r16Num)?.r8Num;

        return (
          <div key={pair.r16Num} className="bracket-pair-column">
            <div className="bracket-r32-pair">
              <R32Card match={mA} />
              <R32Card match={mB} />
            </div>
            <div className="bracket-connector" aria-hidden="true">
              <div className="bracket-connector-lines" />
            </div>
            <div className="bracket-r16-node">
              <span className="bracket-round-tag">Octavos</span>
              <strong>Partido {pair.r16Num}</strong>
              <span className="bracket-round-hint">
                Ganadores P{pair.r32Nums[0]} y P{pair.r32Nums[1]}
              </span>
              {cuartos != null && (
                <span className="bracket-round-next">
                  {side === "right" ? `← Cuartos P${cuartos}` : `→ Cuartos P${cuartos}`}
                </span>
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
}

export function BracketTreeView({ matches, tree }: BracketTreeViewProps) {
  const pairs = tree?.pairs ?? WC2026_BRACKET_PAIRS;
  const sorted = [...matches].sort((a, b) => a.externalNum - b.externalNum);

  if (sorted.length === 0) {
    return null;
  }

  return (
    <div className="bracket-tree-wrap">
      <p className="admin-block-hint bracket-tree-legend">
        Lee el cuadro de afuera hacia adentro: cada par de dieciseisavos alimenta un octavo (89–96) y
        luego cuartos (97–100).
      </p>
      <div className="bracket-tree">
        <BracketHalf side="left" pairs={pairs} matches={sorted} />
        <div className="bracket-tree-center" aria-hidden="true">
          <div className="bracket-final-column">
            <span className="bracket-round-tag">Cuartos</span>
            <span>97 / 98</span>
            <span className="bracket-round-tag" style={{ marginTop: "1.5rem" }}>
              Cuartos
            </span>
            <span>99 / 100</span>
            <span className="bracket-round-tag" style={{ marginTop: "2rem" }}>
              Semis → Final
            </span>
          </div>
        </div>
        <BracketHalf side="right" pairs={pairs} matches={sorted} />
      </div>
    </div>
  );
}
