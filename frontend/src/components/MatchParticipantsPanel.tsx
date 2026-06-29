import { useCallback, useEffect, useState } from "react";
import {
  MatchScoringBreakdownList,
  type MatchScoringBreakdownData
} from "./MatchScoringBreakdownList";
import { api } from "../lib/api";

export function MatchParticipantsPanel({
  matchId,
  open,
  refreshKey = ""
}: {
  matchId: number;
  open: boolean;
  refreshKey?: string | number;
}) {
  const [data, setData] = useState<MatchScoringBreakdownData | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const res = await api<MatchScoringBreakdownData>(`/admin/matches/${matchId}/scoring`);
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
      {data && <MatchScoringBreakdownList data={data} />}
    </div>
  );
}
