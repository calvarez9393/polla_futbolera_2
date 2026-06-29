import { useCallback, useEffect, useRef, useState } from "react";
import { Link } from "react-router-dom";
import { PageTitle } from "../components/InfoModal";
import { PredictionsSubnav } from "../components/PredictionsSubnav";
import {
  PredictionMatchCard,
  type CalendarPredictionMatch,
  type PredictionDraft,
  type PredictionMatchCardHandle
} from "../components/PredictionMatchCard";
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

interface BatchResult {
  saved: number;
  errors: Array<{ matchId: number; message: string }>;
}

const ROUND_ORDER = ["R16", "R8", "R4", "SF", "TP3", "F"];

/** Ronda en juego: la más avanzada (octavos→cuartos→semis→…) que ya tiene algún partido finalizado. */
function latestFinishedRound(rounds: BracketRound[]): string | null {
  let bestKey: string | null = null;
  let bestIdx = -1;
  for (const round of rounds) {
    if (!round.matches.some((m) => m.status === "FINISHED")) continue;
    const idx = ROUND_ORDER.indexOf(round.roundKey);
    if (idx > bestIdx) {
      bestIdx = idx;
      bestKey = round.roundKey;
    }
  }
  return bestKey;
}

export function BracketPage() {
  const [rounds, setRounds] = useState<BracketRound[]>([]);
  const [globalWindow, setGlobalWindow] = useState<{
    openDate: string | null;
    closeDate: string | null;
  } | null>(null);
  const [groupStageComplete, setGroupStageComplete] = useState(false);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [collapsed, setCollapsed] = useState<Set<string>>(new Set());
  const [savingRound, setSavingRound] = useState<string | null>(null);
  const [roundMsg, setRoundMsg] = useState<Record<string, { text: string; error: boolean }>>({});
  const [error, setError] = useState("");
  const cardRefs = useRef<Map<number, PredictionMatchCardHandle | null>>(new Map());
  // Solo en la primera carga enfocamos la ronda en juego; después respetamos lo que abra/cierre el usuario.
  const focusedInitialRound = useRef(false);

  const load = useCallback(async (options?: { silent?: boolean }) => {
    const silent = options?.silent ?? false;
    if (silent) setRefreshing(true);
    else setLoading(true);
    try {
      const data = await api<{
        rounds: BracketRound[];
        knockoutGlobalWindow?: { openDate: string | null; closeDate: string | null };
        groupStageComplete?: boolean;
      }>("/predictions/me/bracket");
      setRounds(data.rounds);
      setGlobalWindow(data.knockoutGlobalWindow ?? null);
      setGroupStageComplete(data.groupStageComplete ?? false);
      setError("");

      // Al entrar, deja abierta solo la ronda más avanzada con partidos finalizados (octavos,
      // cuartos, semis…) y colapsa las demás, para caer directo en lo que se está jugando.
      if (!focusedInitialRound.current && data.rounds.length > 0) {
        focusedInitialRound.current = true;
        const active = latestFinishedRound(data.rounds);
        if (active) {
          setCollapsed(new Set(data.rounds.map((r) => r.roundKey).filter((k) => k !== active)));
        }
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

  function toggleRound(roundKey: string) {
    setCollapsed((prev) => {
      const next = new Set(prev);
      if (next.has(roundKey)) next.delete(roundKey);
      else next.add(roundKey);
      return next;
    });
  }

  const setCardRef = (matchId: number) => (handle: PredictionMatchCardHandle | null) => {
    if (handle) cardRefs.current.set(matchId, handle);
    else cardRefs.current.delete(matchId);
  };

  async function saveRound(round: BracketRound) {
    const drafts: PredictionDraft[] = [];
    for (const match of round.matches) {
      const draft = cardRefs.current.get(Number(match.id))?.getDraft();
      if (draft) drafts.push(draft);
    }
    if (drafts.length === 0) {
      setRoundMsg((prev) => ({
        ...prev,
        [round.roundKey]: { text: "No hay partidos abiertos para guardar en esta ronda.", error: true }
      }));
      return;
    }
    setSavingRound(round.roundKey);
    setRoundMsg((prev) => ({ ...prev, [round.roundKey]: { text: "Guardando ronda…", error: false } }));
    try {
      const res = await api<BatchResult>("/predictions/batch", {
        method: "POST",
        body: JSON.stringify({ predictions: drafts })
      });
      const scrollY = window.scrollY;
      await load({ silent: true });
      requestAnimationFrame(() => window.scrollTo(0, scrollY));
      try {
        await api("/predictions/me/bonuses");
      } catch {
        /* el resumen de bonos se recalcula al abrir Cuadro y premios */
      }
      const failed = res.errors?.length ?? 0;
      setRoundMsg((prev) => ({
        ...prev,
        [round.roundKey]: {
          text:
            failed > 0
              ? `Guardados ${res.saved} de ${drafts.length}. ${failed} no se pudieron guardar: ${res.errors[0].message}`
              : `Guardados ${res.saved} marcadores de la ronda.`,
          error: failed > 0
        }
      }));
    } catch (e) {
      setRoundMsg((prev) => ({
        ...prev,
        [round.roundKey]: { text: (e as Error).message, error: true }
      }));
    } finally {
      setSavingRound(null);
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
            <p>
              Cuando termina la fase de grupos, las eliminatorias se abren solas. Llena cada ronda y usa{" "}
              <strong>Guardar ronda</strong> para enviar todos sus marcadores de una; al guardar, los ganadores avanzan
              y aparece la siguiente ronda.
            </p>
            <p>El plazo de cierre lo define el administrador en Configuración (o el calendario FIFA).</p>
          </>
        }
      >
        Eliminatorias
      </PageTitle>

      <PredictionsSubnav />

      {groupStageComplete && (
        <p className="bracket-group-complete-banner">
          <span aria-hidden>✅</span>
          <span>
            <strong>La fase de grupos terminó.</strong> Las eliminatorias están abiertas
            {globalWindow?.closeDate ? <> hasta el {formatCalendarDateYmd(globalWindow.closeDate)}</> : null}. Puedes
            llenar todos los partidos ahora.
          </span>
        </p>
      )}

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
          <div className="exclusive-accordion">
            {rounds.map((round) => {
              const isOpen = !collapsed.has(round.roundKey);
              const filled = round.matches.filter((m) => m.prediction != null).length;
              const total = round.matches.length;
              const pct = total > 0 ? Math.round((filled / total) * 100) : 0;
              const windowOpen = round.predictionWindow?.isOpen ?? false;
              const msg = roundMsg[round.roundKey];
              return (
                <section
                  key={round.roundKey}
                  className={`exclusive-accordion-item${isOpen ? " exclusive-accordion-item--open" : ""}`}
                >
                  <button
                    type="button"
                    className="exclusive-accordion-trigger"
                    aria-expanded={isOpen}
                    onClick={() => toggleRound(round.roundKey)}
                  >
                    <span className="exclusive-accordion-trigger-main">
                      <span className="exclusive-accordion-title">{round.title}</span>
                      <span className="exclusive-accordion-meta">
                        {filled}/{total} llenado{total === 1 ? "" : "s"}
                      </span>
                    </span>
                    <span className="exclusive-accordion-badge">
                      {round.predictionWindow && !windowOpen ? (
                        <span className="badge badge-scheduled">Cerrada</span>
                      ) : windowOpen ? (
                        <span className="badge badge-finished">Abierta</span>
                      ) : null}
                    </span>
                    <span className="exclusive-accordion-chevron" aria-hidden />
                  </button>
                  {isOpen && (
                    <div className="exclusive-accordion-panel" role="region">
                      {round.predictionWindow && (
                        <p
                          className={`admin-block-hint${windowOpen ? "" : " prediction-card-msg--error"}`}
                          style={{ marginTop: 0, marginBottom: "0.75rem" }}
                        >
                          {windowOpen ? (
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
                      {windowOpen && (
                        <div className="bracket-round-actions">
                          <span className="bracket-progress">
                            <span className="bracket-progress-track">
                              <span className="bracket-progress-fill" style={{ width: `${pct}%` }} />
                            </span>
                            <span className="bracket-progress-label">
                              {filled}/{total}
                            </span>
                          </span>
                          <button
                            type="button"
                            className="btn btn-primary"
                            disabled={savingRound === round.roundKey}
                            onClick={() => saveRound(round)}
                          >
                            {savingRound === round.roundKey ? "Guardando…" : "Guardar ronda"}
                          </button>
                        </div>
                      )}
                      {msg && (
                        <p className={`bracket-round-msg${msg.error ? " bracket-round-msg--error" : ""}`}>
                          {msg.text}
                        </p>
                      )}
                      <div className="match-grid">
                        {round.matches.map((match) => (
                          <PredictionMatchCard
                            key={match.id}
                            ref={setCardRef(Number(match.id))}
                            match={match}
                            onSaved={onMatchSaved}
                            hideKickoffTime
                          />
                        ))}
                      </div>
                    </div>
                  )}
                </section>
              );
            })}
          </div>
        </>
      )}
    </>
  );
}
