import { useCallback, useEffect, useState } from "react";
import { Link } from "react-router-dom";
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
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await api<{
        rounds: BracketRound[];
        knockoutGlobalWindow?: { openDate: string | null; closeDate: string | null };
      }>("/predictions/me/bracket");
      setRounds(data.rounds);
      setGlobalWindow(data.knockoutGlobalWindow ?? null);
      setError("");
    } catch (e) {
      setError((e as Error).message);
      setRounds([]);
    } finally {
      setLoading(false);
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

  return (
    <>
      <h1 className="page-title">Eliminatorias</h1>
      <p className="page-subtitle">
        <strong>Fase 1:</strong> grupos y dieciseisavos — ganador/empate (+3), diferencia (+2), exacto (+5). En
        fase de grupos puedes predecir empate sin elegir ganador. Desde octavos, en empate debes indicar quién
        pasa en penales.{" "}
        <strong>Fase 2:</strong> desde octavos — equipo que avanza y marcador exacto con más puntos por ronda.
        Al guardar un resultado o elegir quién avanza, los equipos pasan solos a octavos, cuartos, semis y
        final en tu simulación; el cuadro oficial hace lo mismo con los resultados reales del admin. Las
        fechas de predicción las define el administrador en Configuración (o el calendario FIFA si no hay
        fechas configuradas).
      </p>

      <PredictionsSubnav />

      {(globalWindow?.openDate || globalWindow?.closeDate) && (
        <p className="admin-block-hint" style={{ marginBottom: "1rem" }}>
          Ventana admin:{" "}
          {globalWindow.openDate ? formatCalendarDateYmd(globalWindow.openDate) : "—"}
          {globalWindow.closeDate
            ? ` – ${formatCalendarDateYmd(globalWindow.closeDate)}`
            : ""}{" "}
          (calendario sede).
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

      {rounds.map((round) => (
        <section key={round.roundKey} style={{ marginBottom: "2rem" }}>
          <h2 className="page-title" style={{ fontSize: "1.15rem", marginBottom: "0.75rem" }}>
            {round.title}
          </h2>
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
              <PredictionMatchCard key={match.id} match={match} onSaved={load} />
            ))}
          </div>
        </section>
      ))}
    </>
  );
}
