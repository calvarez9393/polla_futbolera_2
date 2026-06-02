import { useCallback, useEffect, useState } from "react";
import { PointsChips } from "./PointsChips";
import { api } from "../lib/api";

interface Participant {
  userId: number;
  email: string;
  displayName: string | null;
  predictedHomeScore: number;
  predictedAwayScore: number;
  points: number;
  breakdown: Record<string, number>;
}

interface MatchScoringData {
  match: {
    id: number;
    status: string;
    homeTeamName: string;
    awayTeamName: string;
    homeScore: number | null;
    awayScore: number | null;
  };
  participants: Participant[];
  withoutPrediction: Array<{ userId: number; email: string; displayName: string | null }>;
}

export function MatchParticipantsPanel({
  matchId,
  open,
  refreshKey = ""
}: {
  matchId: number;
  open: boolean;
  refreshKey?: string | number;
}) {
  const [data, setData] = useState<MatchScoringData | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const res = await api<MatchScoringData>(`/admin/matches/${matchId}/scoring`);
      setData(res);
    } catch (e) {
      setError((e as Error).message);
      setData(null);
    } finally {
      setLoading(false);
    }
  }, [matchId]);

  useEffect(() => {
    if (open) load().catch(() => undefined);
  }, [open, load, refreshKey]);

  if (!open) return null;

  return (
    <div className="match-participants-panel">
      <h4>Participantes — predicciones y puntos</h4>
      {loading && <p className="admin-block-hint">Cargando…</p>}
      {error && <p className="admin-block-hint">{error}</p>}
      {data && (
        <>
          {data.participants.length === 0 && data.withoutPrediction.length === 0 && (
            <p className="admin-block-hint">Sin participantes registrados.</p>
          )}
          <ul className="match-participants-list">
            {data.participants.map((p) => (
              <li key={p.userId} className="match-participant-row">
                <div className="match-participant-head">
                  <span>{p.displayName || p.email}</span>
                  <strong>{p.points} pts</strong>
                </div>
                <div className="match-participant-scores">
                  <span className="match-participant-pred">
                    <span className="match-participant-label">Predicción</span>
                    <strong>
                      {p.predictedHomeScore} – {p.predictedAwayScore}
                    </strong>
                  </span>
                  {data.match.homeScore != null && (
                    <span className="match-participant-real">
                      <span className="match-participant-label">Real</span>
                      <strong>
                        {data.match.homeScore} – {data.match.awayScore}
                      </strong>
                    </span>
                  )}
                </div>
                {p.breakdown && Object.keys(p.breakdown).length > 0 && (
                  <PointsChips breakdown={p.breakdown} totalPoints={p.points} />
                )}
              </li>
            ))}
          </ul>
          {data.withoutPrediction.length > 0 && (
            <details style={{ marginTop: "0.75rem" }}>
              <summary className="admin-block-hint">
                Sin predicción ({data.withoutPrediction.length})
              </summary>
              <ul className="match-participants-list">
                {data.withoutPrediction.map((u) => (
                  <li key={u.userId}>{u.displayName || u.email}</li>
                ))}
              </ul>
            </details>
          )}
        </>
      )}
    </div>
  );
}
