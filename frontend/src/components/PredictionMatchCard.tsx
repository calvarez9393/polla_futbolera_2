import { forwardRef, useEffect, useImperativeHandle, useState } from "react";
import { PointsChips } from "./PointsChips";
import { TeamFlag } from "./TeamFlag";
import { api } from "../lib/api";
import { matchCardStatusClass, statusBadgeClass, statusLabel } from "../lib/matchStatus";
import { formatCalendarDateYmd, formatKickoffLocal, formatPredictionLock, formatPredictionWindowRange } from "../lib/matchTime";
import { ROUND_LABELS } from "../lib/scoringLabels";
import {
  advancingTeamIdFromScores,
  isKnockoutMatch,
  nextRoundLabel,
  requiresAdvancingOnDraw,
  showsKnockoutAdvancingUi
} from "../lib/knockoutAdvancing";
import { KnockoutAdvancingBanner } from "./KnockoutAdvancingBanner";
import { MatchGroupPointsModal } from "./MatchGroupPointsModal";
import { MatchupScoreStrip, matchupToTeams } from "./MatchupScoreStrip";
import { sameMatchup, type PredictedMatchup } from "./predictedMatchup";

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
  officialAdvancingTeamId?: number | null;
  officialAdvancingTeamName?: string | null;
  officialAdvancingTeamLogoUrl?: string | null;
  officialAdvancingViaPenalties?: boolean;
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
  predictedMatchup?: PredictedMatchup | null;
  officialMatchup?: PredictedMatchup | null;
  officialMatchupDefined?: boolean;
  earnedPoints: number | null;
  earnedBreakdown: Record<string, number> | null;
}

interface PredictionMatchCardProps {
  match: CalendarPredictionMatch;
  onSaved?: () => void;
  readOnly?: boolean;
}

/** Borrador listo para enviar al endpoint de pronósticos. */
export interface PredictionDraft {
  matchId: number;
  predictedHomeScore: number;
  predictedAwayScore: number;
  predictedAdvancingTeamId?: number;
}

/** Handle imperativo para que el padre (guardado por ronda) recoja el borrador actual. */
export interface PredictionMatchCardHandle {
  /** Borrador válido si la tarjeta es editable y completa; null si está cerrada o incompleta. */
  getDraft: () => PredictionDraft | null;
}

export const PredictionMatchCard = forwardRef<PredictionMatchCardHandle, PredictionMatchCardProps>(
  function PredictionMatchCard({ match, onSaved, readOnly = false }, ref) {
  const [predHome, setPredHome] = useState(String(match.prediction?.predictedHomeScore ?? 0));
  const [predAway, setPredAway] = useState(String(match.prediction?.predictedAwayScore ?? 0));
  const [advancingId, setAdvancingId] = useState<number | "">(
    match.prediction?.predictedAdvancingTeamId ?? ""
  );
  const [saving, setSaving] = useState(false);
  const [localMsg, setLocalMsg] = useState("");
  const [isError, setIsError] = useState(false);
  const [groupPointsOpen, setGroupPointsOpen] = useState(false);

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
  const showKickoffTime = !isKnockoutMatch(match.stage, match.roundKey);

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

  useImperativeHandle(
    ref,
    () => ({
      getDraft() {
        if (readOnly || !canPredict) return null;
        if (needsAdvancingOnDraw && isDrawPrediction && !effectiveAdvancingId) return null;
        const draft: PredictionDraft = {
          matchId: Number(match.id),
          predictedHomeScore: predHomeNum,
          predictedAwayScore: predAwayNum
        };
        if (showAdvancingUi && effectiveAdvancingId) {
          draft.predictedAdvancingTeamId = effectiveAdvancingId;
        }
        return draft;
      }
    }),
    [
      readOnly,
      canPredict,
      needsAdvancingOnDraw,
      isDrawPrediction,
      effectiveAdvancingId,
      match.id,
      predHomeNum,
      predAwayNum,
      showAdvancingUi
    ]
  );

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

  const predictedAdvancingName =
    match.prediction && match.advancingTeamName
      ? match.advancingTeamName
      : displayAdvancingName;

  const predictedAdvancingLogo =
    match.advancingTeamLogoUrl ?? displayAdvancingLogo;

  const predictedAdvancingViaPenalties =
    match.prediction != null
      ? match.advancingViaPenalties ??
        (showAdvancingUi &&
          match.prediction.predictedHomeScore === match.prediction.predictedAwayScore &&
          Boolean(match.advancingTeamId ?? effectiveAdvancingId))
      : false;

  const savedMatchup =
    match.stage === "KNOCKOUT" && match.prediction && match.predictedMatchup
      ? match.predictedMatchup
      : null;
  const currentMatchup =
    match.homeTeamId != null && match.awayTeamId != null
      ? { homeTeamId: match.homeTeamId, awayTeamId: match.awayTeamId }
      : null;
  const matchupDiffers =
    savedMatchup != null &&
    currentMatchup != null &&
    !sameMatchup(savedMatchup, currentMatchup);

  const showSavedInHeader =
    match.stage === "KNOCKOUT" && match.prediction != null && savedMatchup != null;

  const officialTeams = match.officialMatchup ? matchupToTeams(match.officialMatchup) : null;
  // Cruce real ya definido (ambos clasificados conocidos): mostrarlo abajo apenas se conoce la
  // llave, sin esperar el resultado y aunque coincida con lo que predijo el usuario.
  const showOfficialEarly =
    officialTeams != null &&
    match.status !== "FINISHED" &&
    Boolean(match.officialMatchupDefined);

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
      {showSavedInHeader ? (
        <>
          <MatchupScoreStrip
            className="matchup-score-strip--in-card"
            variant="prediction"
            label="Partido que predijiste"
            teams={{
              homeTeamName: savedMatchup.homeTeamName,
              homeTeamLogoUrl: savedMatchup.homeTeamLogoUrl,
              awayTeamName: savedMatchup.awayTeamName,
              awayTeamLogoUrl: savedMatchup.awayTeamLogoUrl
            }}
            homeScore={match.prediction!.predictedHomeScore}
            awayScore={match.prediction!.predictedAwayScore}
          />
          {match.status === "FINISHED" && officialTeams && (
            <MatchupScoreStrip
              className="matchup-score-strip--in-card matchup-score-strip--official"
              variant="compact"
              label="Resultado real"
              teams={officialTeams}
              homeScore={match.homeScore}
              awayScore={match.awayScore}
            />
          )}
          {showOfficialEarly && officialTeams && (
            <MatchupScoreStrip
              className="matchup-score-strip--in-card matchup-score-strip--official"
              variant="compact"
              label="Cruce real (ya definido)"
              teams={officialTeams}
              homeScore={match.homeScore}
              awayScore={match.awayScore}
            />
          )}
          {matchupDiffers && canPredict && (
            <MatchupScoreStrip
              className="matchup-score-strip--in-card matchup-score-strip--current"
              variant="compact"
              label="Cuadro actual (si guardas de nuevo)"
              teams={{
                homeTeamName: match.homeTeamName,
                homeTeamLogoUrl: match.homeTeamLogoUrl,
                awayTeamName: match.awayTeamName,
                awayTeamLogoUrl: match.awayTeamLogoUrl
              }}
              homeScore={null}
              awayScore={null}
            />
          )}
        </>
      ) : match.status === "FINISHED" && officialTeams ? (
        <MatchupScoreStrip
          className="matchup-score-strip--in-card matchup-score-strip--official"
          label="Resultado real"
          teams={officialTeams}
          homeScore={match.homeScore}
          awayScore={match.awayScore}
        />
      ) : (
        <>
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
        </>
      )}

      {showAdvancingUi && match.prediction && predictedAdvancingName && (
        <KnockoutAdvancingBanner
          kind="prediction"
          teamName={predictedAdvancingName}
          logoUrl={predictedAdvancingLogo}
          nextRoundLabel={nextLabel}
          viaPenalties={predictedAdvancingViaPenalties}
        />
      )}

      {showAdvancingUi &&
        match.status === "FINISHED" &&
        match.officialAdvancingTeamName && (
          <KnockoutAdvancingBanner
            kind="official"
            teamName={match.officialAdvancingTeamName}
            logoUrl={match.officialAdvancingTeamLogoUrl}
            nextRoundLabel={nextLabel}
            viaPenalties={match.officialAdvancingViaPenalties}
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
        {showKickoffTime && (
          <span>
            {formatKickoffLocal({ kickoff_time_local: match.kickoffTimeLocal, starts_at: match.startsAt })}{" "}
            (hora sede)
          </span>
        )}
        {canPredict ? (
          <span className="badge badge-scheduled">
            Abierto hasta{" "}
            {match.stage === "KNOCKOUT" && match.predictionWindow
              ? formatCalendarDateYmd(match.predictionWindow.closeDate)
              : formatPredictionLock(match.predictionLockAt)}
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
        {!showSavedInHeader && <p className="prediction-card-label">Tu predicción</p>}
        {showSavedInHeader && canPredict && (
          <p className="prediction-card-label">Actualizar marcador</p>
        )}
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
            {!showSavedInHeader && (
              <p className="prediction-card-readonly">
                {match.prediction
                  ? `${match.prediction.predictedHomeScore} : ${match.prediction.predictedAwayScore}`
                  : "Sin predicción"}
              </p>
            )}
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
            {!readOnly && (
              <button
                type="button"
                className="btn match-group-points-btn"
                onClick={() => setGroupPointsOpen(true)}
              >
                Ver puntos de todos
              </button>
            )}
          </div>
        )}

        {!readOnly && (
          <MatchGroupPointsModal
            matchId={Number(match.id)}
            homeTeamName={match.homeTeamName}
            awayTeamName={match.awayTeamName}
            homeScore={match.homeScore}
            awayScore={match.awayScore}
            open={groupPointsOpen}
            onClose={() => setGroupPointsOpen(false)}
          />
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
);
