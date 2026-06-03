import { useEffect, useState } from "react";
import { PointsChips } from "./PointsChips";
import { TeamFlag } from "./TeamFlag";
import { api } from "../lib/api";
import { matchCardStatusClass, statusBadgeClass, statusLabel } from "../lib/matchStatus";
import { formatKickoffLocal, formatPredictionLock, formatPredictionWindowRange } from "../lib/matchTime";
import { ROUND_LABELS } from "../lib/scoringLabels";
import {
  advancingTeamIdFromScores,
  nextRoundLabel,
  requiresAdvancingOnDraw,
  showsKnockoutAdvancingUi
} from "../lib/knockoutAdvancing";
import { KnockoutAdvancingBanner } from "./KnockoutAdvancingBanner";

export interface CalendarPredictionMatch {
  id: number | string;
  stage?: string;
  status: string;
  roundKey?: string | null;
  startsAt: string;
  kickoffTimeLocal?: string | null;
  roundLabel: string | null;
  matchday: number | null;
  groupName: string | null;
  homeTeamId?: number;
  homeTeamName: string;
  homeTeamLogoUrl?: string | null;
  awayTeamId?: number;
  awayTeamName: string;
  awayTeamLogoUrl?: string | null;
  homeScore: number | null;
  awayScore: number | null;
  winnerTeamId?: number | null;
  advancingTeamId?: number | null;
  advancingTeamName?: string | null;
  advancingTeamLogoUrl?: string | null;
  advancingViaPenalties?: boolean;
  nextRoundLabel?: string | null;
  predictionsOpen: boolean;
  predictionLockAt: string;
  predictionWindow?: {
    openDate: string;
    closeDate: string;
    isOpen: boolean;
    globalOpenDate?: string | null;
    globalCloseDate?: string | null;
    source?: "admin" | "fixture";
  } | null;
  prediction: {
    predictedHomeScore: number;
    predictedAwayScore: number;
    predictedAdvancingTeamId?: number | null;
  } | null;
  earnedPoints: number | null;
  earnedBreakdown: Record<string, number> | null;
}

interface PredictionMatchCardProps {
  match: CalendarPredictionMatch;
  onSaved?: () => void;
  readOnly?: boolean;
}

export function PredictionMatchCard({ match, onSaved, readOnly = false }: PredictionMatchCardProps) {
  const [predHome, setPredHome] = useState(String(match.prediction?.predictedHomeScore ?? 0));
  const [predAway, setPredAway] = useState(String(match.prediction?.predictedAwayScore ?? 0));
  const [advancingId, setAdvancingId] = useState<number | "">(
    match.prediction?.predictedAdvancingTeamId ?? ""
  );
  const [saving, setSaving] = useState(false);
  const [localMsg, setLocalMsg] = useState("");
  const [isError, setIsError] = useState(false);

  const predHomeNum = parseInt(predHome, 10) || 0;
  const predAwayNum = parseInt(predAway, 10) || 0;

  const needsAdvancingOnDraw = requiresAdvancingOnDraw(match.stage, match.roundKey);
  const showAdvancingUi = showsKnockoutAdvancingUi(match.stage, match.roundKey);
  const isDrawPrediction = predHomeNum === predAwayNum;
  const nextLabel = match.nextRoundLabel ?? nextRoundLabel(match.roundKey);
  const canPredict =
    match.predictionsOpen && match.status !== "FINISHED" && match.status !== "LIVE";
  const windowClosed =
    match.predictionWindow != null && !match.predictionWindow.isOpen;
  const showPoints = match.status === "FINISHED";

  useEffect(() => {
    setPredHome(String(match.prediction?.predictedHomeScore ?? 0));
    setPredAway(String(match.prediction?.predictedAwayScore ?? 0));
    const savedAdv =
      match.prediction?.predictedAdvancingTeamId ??
      (match.advancingViaPenalties ? match.advancingTeamId : null);
    setAdvancingId(savedAdv ?? "");
  }, [match]);

  useEffect(() => {
    if (!showAdvancingUi || !canPredict) return;
    if (predHomeNum === predAwayNum) return;
    const auto = advancingTeamIdFromScores(
      predHomeNum,
      predAwayNum,
      match.homeTeamId,
      match.awayTeamId
    );
    if (auto) setAdvancingId(auto);
  }, [predHome, predAway, showAdvancingUi, canPredict, match.homeTeamId, match.awayTeamId]);

  const effectiveAdvancingId =
    advancingId !== ""
      ? Number(advancingId)
      : match.prediction?.predictedAdvancingTeamId ?? match.advancingTeamId ?? null;

  const displayAdvancingName =
    effectiveAdvancingId === match.homeTeamId
      ? match.homeTeamName
      : effectiveAdvancingId === match.awayTeamId
        ? match.awayTeamName
        : match.advancingTeamName ?? null;

  const displayAdvancingLogo =
    effectiveAdvancingId === match.homeTeamId
      ? match.homeTeamLogoUrl
      : effectiveAdvancingId === match.awayTeamId
        ? match.awayTeamLogoUrl
        : match.advancingTeamLogoUrl;

  const displayViaPenalties = showAdvancingUi && isDrawPrediction && Boolean(effectiveAdvancingId);

  async function savePrediction() {
    if (needsAdvancingOnDraw && isDrawPrediction && !effectiveAdvancingId) {
      setIsError(true);
      setLocalMsg("En empate indica quién gana en penales y pasa a la siguiente ronda");
      return;
    }
    setSaving(true);
    setLocalMsg("");
    try {
      const payload: {
        matchId: number;
        predictedHomeScore: number;
        predictedAwayScore: number;
        predictedAdvancingTeamId?: number;
      } = {
        matchId: Number(match.id),
        predictedHomeScore: predHomeNum,
        predictedAwayScore: predAwayNum
      };
      if (showAdvancingUi && effectiveAdvancingId) {
        payload.predictedAdvancingTeamId = effectiveAdvancingId;
      }
      await api("/predictions", {
        method: "POST",
        body: JSON.stringify(payload)
      });
      setIsError(false);
      setLocalMsg("Predicción guardada");
      onSaved?.();
    } catch (e) {
      setIsError(true);
      setLocalMsg((e as Error).message);
    } finally {
      setSaving(false);
    }
  }

  return (
    <article className={`match-card prediction-match-card${matchCardStatusClass(match.status)}${match.prediction != null ? " prediction-match-card--filled" : ""}`}>
      <div className="match-team home">
        <span className="match-team-name">{match.homeTeamName}</span>
        <TeamFlag name={match.homeTeamName} logoUrl={match.homeTeamLogoUrl} size="lg" />
      </div>
      <div className="match-score">
        {match.homeScore ?? "–"} : {match.awayScore ?? "–"}
      </div>
      <div className="match-team away">
        <TeamFlag name={match.awayTeamName} logoUrl={match.awayTeamLogoUrl} size="lg" />
        <span className="match-team-name">{match.awayTeamName}</span>
      </div>

      {showAdvancingUi && displayAdvancingName && (
        <KnockoutAdvancingBanner
          teamName={displayAdvancingName}
          logoUrl={match.advancingTeamLogoUrl ?? displayAdvancingLogo}
          nextRoundLabel={nextLabel}
          viaPenalties={displayViaPenalties}
        />
      )}

      <div className="match-meta">
        <span className={statusBadgeClass(match.status)}>{statusLabel(match.status)}</span>
        {match.roundKey && ROUND_LABELS[match.roundKey] && (
          <span className="badge badge-scheduled">{ROUND_LABELS[match.roundKey]}</span>
        )}
        {match.groupName && <span className="badge badge-scheduled">{match.groupName}</span>}
        {match.roundLabel && <span>{match.roundLabel}</span>}
        {match.matchday != null && <span>Fecha {match.matchday}</span>}
        <span>{formatKickoffLocal({ kickoff_time_local: match.kickoffTimeLocal, starts_at: match.startsAt })} (hora sede)</span>
        {canPredict ? (
          <span className="badge badge-scheduled">
            Abierto hasta {formatPredictionLock(match.predictionLockAt)}
          </span>
        ) : windowClosed && match.predictionWindow ? (
          <span className="badge badge-live">
            Fuera de ventana{" "}
            {match.predictionWindow.source === "admin" ? "admin" : "FIFA"} (
            {formatPredictionWindowRange(
              match.predictionWindow.openDate,
              match.predictionWindow.closeDate
            )}
            )
          </span>
        ) : (
          <span className="badge badge-live">Predicción cerrada</span>
        )}
      </div>

      {!readOnly && (
      <div className="prediction-card-body">
        <p className="prediction-card-label">Tu predicción</p>
        {canPredict ? (
          <>
            <div className="score-inputs prediction-card-scores">
              <input
                className="input"
                type="text"
                inputMode="numeric"
                pattern="[0-9]*"
                aria-label="Goles local"
                value={predHome}
                onFocus={(e) => e.target.select()}
                onChange={(e) => setPredHome(e.target.value.replace(/[^0-9]/g, ""))}
              />
              <span className="score-sep">:</span>
              <input
                className="input"
                type="text"
                inputMode="numeric"
                pattern="[0-9]*"
                aria-label="Goles visitante"
                value={predAway}
                onFocus={(e) => e.target.select()}
                onChange={(e) => setPredAway(e.target.value.replace(/[^0-9]/g, ""))}
              />
            </div>
            {showAdvancingUi && isDrawPrediction && match.homeTeamId && match.awayTeamId && (
              <div className="field" style={{ width: "100%", maxWidth: 320 }}>
                <label>
                  Gana en penales y pasa a {nextLabel}
                  {!needsAdvancingOnDraw && (
                    <span style={{ fontWeight: 400, color: "var(--text-muted)" }}> (opcional)</span>
                  )}
                </label>
                <select
                  className="select"
                  value={advancingId !== "" ? String(advancingId) : ""}
                  onChange={(e) =>
                    setAdvancingId(e.target.value ? Number(e.target.value) : "")
                  }
                >
                  <option value="">Elegir equipo…</option>
                  <option value={String(match.homeTeamId)}>{match.homeTeamName}</option>
                  <option value={String(match.awayTeamId)}>{match.awayTeamName}</option>
                </select>
              </div>
            )}
            {showAdvancingUi && !isDrawPrediction && displayAdvancingName && (
              <p className="admin-block-hint" style={{ margin: 0 }}>
                Con tu marcador pasa <strong>{displayAdvancingName}</strong> a {nextLabel}.
              </p>
            )}
            <button type="button" className="btn btn-primary" disabled={saving} onClick={savePrediction}>
              {saving ? "Guardando…" : match.prediction ? "Actualizar predicción" : "Guardar predicción"}
            </button>
          </>
        ) : (
          <>
            <p className="prediction-card-readonly">
              {match.prediction
                ? `${match.prediction.predictedHomeScore} : ${match.prediction.predictedAwayScore}`
                : "Sin predicción"}
            </p>
            {windowClosed && match.predictionWindow && (
              <p className="admin-block-hint" style={{ margin: 0 }}>
                Ventana{" "}
                {match.predictionWindow.source === "admin" ? "admin" : "FIFA"}:{" "}
                {formatPredictionWindowRange(
                  match.predictionWindow.openDate,
                  match.predictionWindow.closeDate
                )}{" "}
                (calendario sede).
              </p>
            )}
          </>
        )}

        {showPoints && (
          <div className="prediction-card-points">
            <p className="prediction-card-label">Puntos obtenidos</p>
            <PointsChips breakdown={match.earnedBreakdown} totalPoints={match.earnedPoints} />
          </div>
        )}

        {localMsg && (
          <p className={`prediction-card-msg${isError ? " prediction-card-msg--error" : ""}`}>
            {localMsg}
          </p>
        )}
      </div>
      )}
    </article>
  );
}
