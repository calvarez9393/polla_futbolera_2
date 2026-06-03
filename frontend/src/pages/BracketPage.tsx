import { useCallback, useEffect, useRef, useState } from "react";
import { Link } from "react-router-dom";
import { PageTitle } from "../components/InfoModal";
import { ExclusiveAccordion } from "../components/ExclusiveAccordion";
import { PredictionsSubnav } from "../components/PredictionsSubnav";
import { PredictionMatchCard, type CalendarPredictionMatch } from "../components/PredictionMatchCard";
import { api } from "../lib/api";

import { formatCalendarDateYmd, formatPredictionWindowRange } from "../lib/matchTime";

interface BracketRound {
  roundKey: string;
  title: string;
  predictionWindow?: {
    openDate: string;
    closeDate: string;
    isOpen: boolean;
  } | null;
  matches: CalendarPredictionMatch[];
}

export function BracketPage() {
  const [rounds, setRounds] = useState<BracketRound[]>([]);
  const [globalWindow, setGlobalWindow] = useState<{
    openDate: string | null;
    closeDate: string | null;
  } | null>(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [openRoundKey, setOpenRoundKey] = useState<string | null>(null);
  const [error, setError] = useState("");
  const initialOpenSet = useRef(false);

  const load = useCallback(async (options?: { silent?: boolean }) => {
    const silent = options?.silent ?? false;
    if (silent) setRefreshing(true);
    else setLoading(true);
    try {
      const data = await api<{
        rounds: BracketRound[];
        knockoutGlobalWindow?: { openDate: string | null; closeDate: string | null };
      }>("/predictions/me/bracket");
      setRounds(data.rounds);
      setGlobalWindow(data.knockoutGlobalWindow ?? null);
      setError("");
      if (!initialOpenSet.current && data.rounds.length > 0) {
        setOpenRoundKey(data.rounds[0].roundKey);
        initialOpenSet.current = true;
      }
    } catch (e) {
      setError((e as Error).message);
      if (!silent) setRounds([]);
    } finally {
      if (silent) setRefreshing(false);
      else setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  useEffect(() => {
    const refresh = () => {
      if (document.visibilityState === "visible") load();
    };
    document.addEventListener("visibilitychange", refresh);
    return () => document.removeEventListener("visibilitychange", refresh);
  }, [load]);

  async function onMatchSaved() {
    const scrollY = window.scrollY;
    await load({ silent: true });
    requestAnimationFrame(() => {
      window.scrollTo(0, scrollY);
    });
    try {
      await api("/predictions/me/bonuses");
    } catch {
      /* resumen en Cuadro y premios se actualiza al abrir esa página */
    }
  }

  return (
    <>
      <PageTitle
        helpTitle="Eliminatorias"
        help={
          <>
            <p>
              <strong>Dieciseisavos:</strong> los cruces parten de los equipos que clasificaron realmente (resultados
              oficiales de grupos). Desde octavos, tu simulación avanza según tus marcadores y quién elijas que pasa.
            </p>
            <p>
              <strong>Fase 1:</strong> grupos y dieciseisavos — ganador/empate (+3), diferencia (+2), exacto (+5).
              En fase de grupos puedes predecir empate sin elegir ganador. Desde octavos, en empate debes indicar
              quién pasa en penales.
            </p>
            <p>
              <strong>Fase 2:</strong> desde octavos — equipo que avanza y marcador exacto con más puntos por ronda.
              Al guardar, los equipos pasan solos a octavos, cuartos, semis y final en tu simulación.
            </p>
            <p>Las fechas de predicción las define el administrador en Configuración (o el calendario FIFA).</p>
          </>
        }
      >
        Eliminatorias
      </PageTitle>

      <PredictionsSubnav />

      {(globalWindow?.openDate || globalWindow?.closeDate) && (
        <p className="admin-ko-callout-stats" style={{ marginBottom: "1rem" }}>
          Ventana:{" "}
          {globalWindow.openDate ? formatCalendarDateYmd(globalWindow.openDate) : "—"}
          {globalWindow.closeDate ? ` – ${formatCalendarDateYmd(globalWindow.closeDate)}` : ""}
        </p>
      )}

      {error && <div className="alert alert-error">{error}</div>}

      {rounds.length === 0 && !loading && (
        <div className="panel-card empty-state">
          <strong>Sin partidos eliminatorios</strong>
          <p style={{ marginTop: "0.5rem" }}>
            El admin debe importar el cuadro desde{" "}
            <Link to="/admin">Configuración</Link> → Importar eliminatorias 2026.
          </p>
        </div>
      )}

      {loading && (
        <div className="panel-card empty-state">
          <strong>Cargando cuadro…</strong>
        </div>
      )}

      {!loading && rounds.length > 0 && (
        <>
          {refreshing && (
            <p className="bracket-refresh-hint" aria-live="polite">
              Actualizando cuadro…
            </p>
          )}
          <ExclusiveAccordion
            openId={openRoundKey}
            onOpenIdChange={setOpenRoundKey}
            items={rounds.map((round) => ({
            id: round.roundKey,
            title: round.title,
            meta: `${round.matches.length} partido${round.matches.length === 1 ? "" : "s"}`,
            badge:
              round.predictionWindow && !round.predictionWindow.isOpen ? (
                <span className="badge badge-scheduled">Cerrada</span>
              ) : round.predictionWindow?.isOpen ? (
                <span className="badge badge-finished">Abierta</span>
              ) : null,
            children: (
              <>
                {round.predictionWindow && (
                  <p
                    className={`admin-block-hint${round.predictionWindow.isOpen ? "" : " prediction-card-msg--error"}`}
                    style={{ marginTop: 0, marginBottom: "0.75rem" }}
                  >
                    {round.predictionWindow.isOpen ? (
                      <>
                        Ventana abierta:{" "}
                        {formatPredictionWindowRange(
                          round.predictionWindow.openDate,
                          round.predictionWindow.closeDate
                        )}
                        .
                      </>
                    ) : (
                      <>
                        Fuera de ventana (
                        {formatPredictionWindowRange(
                          round.predictionWindow.openDate,
                          round.predictionWindow.closeDate
                        )}
                        ).
                      </>
                    )}
                  </p>
                )}
                <div className="match-grid">
                  {round.matches.map((match) => (
                    <PredictionMatchCard key={match.id} match={match} onSaved={onMatchSaved} />
                  ))}
                </div>
              </>
            )
          }))}
          />
        </>
      )}
    </>
  );
}
