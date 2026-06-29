import { PointsChips } from "./PointsChips";

export interface MatchScoringParticipant {
  userId: number;
  email: string;
  displayName: string | null;
  predictedHomeScore: number;
  predictedAwayScore: number;
  predictedAdvancingTeamName?: string | null;
  bracketHomeTeamName?: string | null;
  bracketAwayTeamName?: string | null;
  sameMatchup?: boolean | null;
  points: number;
  breakdown: Record<string, number>;
}

export interface MatchScoringBreakdownData {
  match: {
    id: number;
    status: string;
    stage?: string | null;
    homeTeamName: string;
    awayTeamName: string;
    homeScore: number | null;
    awayScore: number | null;
  };
  participants: MatchScoringParticipant[];
  withoutPrediction: Array<{ userId: number; email: string; displayName: string | null }>;
}

function participantLabel(p: { displayName: string | null; email: string }): string {
  return p.displayName?.trim() || p.email;
}

export function MatchScoringBreakdownList({
  data,
  currentUserId,
  compact = false
}: {
  data: MatchScoringBreakdownData;
  currentUserId?: number | null;
  compact?: boolean;
}) {
  const { match, participants, withoutPrediction } = data;

  if (participants.length === 0 && withoutPrediction.length === 0) {
    return <p className="admin-block-hint">Sin participantes registrados.</p>;
  }

  return (
    <>
      {participants.length > 0 && (
        <ul
          className={`match-participants-list match-participants-list--striped${compact ? " match-participants-list--compact" : ""}`}
        >
          {participants.map((p) => {
            const isSelf = currentUserId != null && p.userId === currentUserId;
            return (
              <li
                key={p.userId}
                className={`match-participant-row${isSelf ? " match-participant-row--self" : ""}`}
              >
                <div className="match-participant-head">
                  <span>
                    {participantLabel(p)}
                    {isSelf && <span className="match-participant-you"> (tú)</span>}
                  </span>
                  <strong>{p.points} pts</strong>
                </div>
                <div className="match-participant-scores">
                  <span className="match-participant-pred">
                    <span className="match-participant-label">Predicción</span>
                    <strong>
                      {p.predictedHomeScore} – {p.predictedAwayScore}
                    </strong>
                  </span>
                  {match.homeScore != null && (
                    <span className="match-participant-real">
                      <span className="match-participant-label">Real</span>
                      <strong>
                        {match.homeScore} – {match.awayScore}
                      </strong>
                    </span>
                  )}
                </div>
                {match.stage === "KNOCKOUT" && p.bracketHomeTeamName && p.bracketAwayTeamName && (
                  <p className="match-participant-ko">
                    Su cruce: <strong>{p.bracketHomeTeamName}</strong> vs{" "}
                    <strong>{p.bracketAwayTeamName}</strong>
                    {p.predictedAdvancingTeamName && (
                      <>
                        {" "}
                        · Avanza: <strong>{p.predictedAdvancingTeamName}</strong>
                      </>
                    )}
                    {p.sameMatchup === false && (
                      <span className="match-participant-ko-note">
                        {" "}
                        — cruce distinto al oficial: solo puntúa el equipo que avanza
                      </span>
                    )}
                  </p>
                )}
                {Object.keys(p.breakdown).length > 0 && (
                  <PointsChips breakdown={p.breakdown} totalPoints={p.points} />
                )}
              </li>
            );
          })}
        </ul>
      )}

      {withoutPrediction.length > 0 && (
        <details className="match-participants-accordion match-participants-accordion--nested">
          <summary className="match-participants-summary">
            Sin predicción ({withoutPrediction.length})
          </summary>
          <ul className="match-participants-list match-participants-list--compact match-participants-list--striped">
            {withoutPrediction.map((u) => (
              <li key={u.userId} className="match-participant-nopred">
                <span>
                  {participantLabel(u)}
                  {currentUserId != null && u.userId === currentUserId && (
                    <span className="match-participant-you"> (tú)</span>
                  )}
                </span>
              </li>
            ))}
          </ul>
        </details>
      )}
    </>
  );
}
