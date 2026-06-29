import { useCallback, useEffect, useState } from "react";
import { Modal } from "./Modal";
import {
  MatchScoringBreakdownList,
  type MatchScoringBreakdownData
} from "./MatchScoringBreakdownList";
import { api } from "../lib/api";
import { getUser } from "../lib/auth";

interface MatchGroupPointsModalProps {
  matchId: number;
  homeTeamName: string;
  awayTeamName: string;
  homeScore: number | null;
  awayScore: number | null;
  open: boolean;
  onClose: () => void;
}

export function MatchGroupPointsModal({
  matchId,
  homeTeamName,
  awayTeamName,
  homeScore,
  awayScore,
  open,
  onClose
}: MatchGroupPointsModalProps) {
  const [data, setData] = useState<MatchScoringBreakdownData | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const currentUserId = getUser()?.id ?? null;

  const load = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const res = await api<MatchScoringBreakdownData>(`/predictions/matches/${matchId}/scoring`);
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
  }, [open, load]);

  const resultLabel =
    homeScore != null && awayScore != null
      ? `${homeScore} – ${awayScore}`
      : null;

  return (
    <Modal
      title="Puntos del grupo"
      open={open}
      onClose={onClose}
      wide
    >
      <p className="match-group-points-intro">
        <strong>
          {homeTeamName} vs {awayTeamName}
        </strong>
        {resultLabel && <> · Resultado oficial: {resultLabel}</>}
      </p>
      <p className="admin-block-hint" style={{ marginTop: 0 }}>
        Predicciones y puntos de todos los participantes en este partido.
      </p>

      {loading && <p className="admin-block-hint">Cargando…</p>}
      {error && <p className="prediction-card-msg prediction-card-msg--error">{error}</p>}
      {data && (
        <MatchScoringBreakdownList data={data} currentUserId={currentUserId} />
      )}
    </Modal>
  );
}
