import { useCallback, useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { DateNavigator } from "../components/DateNavigator";
import { PageTitle } from "../components/InfoModal";
import { PredictionsSubnav } from "../components/PredictionsSubnav";
import {
  PredictionMatchCard,
  type CalendarPredictionMatch
} from "../components/PredictionMatchCard";
import { api } from "../lib/api";
import { getToken } from "../lib/auth";
import { toDateInputValue } from "../lib/date";

interface DateRow {
  match_date: string;
  match_count: number;
}

interface PublicMatchRow {
  id: number | string;
  status: string;
  round_key?: string | null;
  starts_at: string;
  kickoff_time_local?: string | null;
  round_label: string | null;
  matchday: number | null;
  group_name: string | null;
  home_team_name: string;
  home_team_logo_url?: string | null;
  away_team_name: string;
  away_team_logo_url?: string | null;
  home_score: number | null;
  away_score: number | null;
  predictions_open: boolean;
  prediction_lock_at_computed: string;
}

function mapPublicMatch(row: PublicMatchRow): CalendarPredictionMatch {
  return {
    id: row.id,
    status: row.status,
    roundKey: row.round_key,
    startsAt: row.starts_at,
    kickoffTimeLocal: row.kickoff_time_local,
    roundLabel: row.round_label,
    matchday: row.matchday,
    groupName: row.group_name,
    homeTeamName: row.home_team_name,
    homeTeamLogoUrl: row.home_team_logo_url,
    awayTeamName: row.away_team_name,
    awayTeamLogoUrl: row.away_team_logo_url,
    homeScore: row.home_score,
    awayScore: row.away_score,
    predictionsOpen: row.predictions_open,
    predictionLockAt: row.prediction_lock_at_computed,
    prediction: null,
    earnedPoints: null,
    earnedBreakdown: null
  };
}

export function PredictionsPage() {
  const token = getToken();
  const [selectedDate, setSelectedDate] = useState(toDateInputValue(new Date()));
  const [dates, setDates] = useState<DateRow[]>([]);
  const [stageFilter, setStageFilter] = useState<"" | "GROUP" | "KNOCKOUT">("GROUP");
  const [matches, setMatches] = useState<CalendarPredictionMatch[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  function applyLoadedDates(rows: DateRow[]) {
    setDates(rows);
    if (rows.length === 0) return;
    const keys = rows.map((d) => String(d.match_date).slice(0, 10));
    setSelectedDate((current) =>
      keys.includes(current) ? current : (keys.find((k) => k.startsWith("2026-06")) ?? keys[0])
    );
  }

  useEffect(() => {
    const params = stageFilter ? `?stage=${stageFilter}` : "";
    api<DateRow[]>(`/matches/dates${params}`)
      .then(applyLoadedDates)
      .catch(() => setDates([]));
  }, [stageFilter]);

  const loadCalendar = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const params = new URLSearchParams({ date: selectedDate });
      if (stageFilter) params.set("stage", stageFilter);

      if (token) {
        const data = await api<{ matches: CalendarPredictionMatch[] }>(
          `/predictions/me/calendar?${params}`
        );
        setMatches(data.matches);
      } else {
        const rows = await api<PublicMatchRow[]>(`/matches?${params}`);
        setMatches(rows.map(mapPublicMatch));
      }
    } catch (e) {
      setError((e as Error).message);
      setMatches([]);
    } finally {
      setLoading(false);
    }
  }, [selectedDate, stageFilter, token]);

  useEffect(() => {
    loadCalendar();
  }, [loadCalendar]);

  return (
    <>
      <PageTitle
        helpTitle="Calendario y predicciones"
        help={
          <p>
            Todos los partidos del Mundial por día.{" "}
            {token ? "Registra tu marcador y revisa tus puntos." : "Inicia sesión para predecir."}
          </p>
        }
      >
        Calendario y predicciones
      </PageTitle>

      {!token && (
        <div className="panel-card" style={{ marginBottom: "1rem", padding: "1rem 1.25rem" }}>
          <Link to="/login" className="btn btn-primary">
            Entrar para hacer predicciones
          </Link>
          <span style={{ marginLeft: "0.75rem", color: "var(--text-muted)", fontSize: "0.85rem" }}>
            Solo participantes registrados por el administrador.
          </span>
        </div>
      )}

      {token && <PredictionsSubnav />}

      <DateNavigator selectedDate={selectedDate} onChange={setSelectedDate} dates={dates} />

      <div className="filter-row">
        <button
          type="button"
          className={`btn btn-ghost${stageFilter === "GROUP" ? " active-filter" : ""}`}
          onClick={() => setStageFilter("GROUP")}
        >
          Fase de grupos
        </button>
        <button
          type="button"
          className={`btn btn-ghost${stageFilter === "KNOCKOUT" ? " active-filter" : ""}`}
          onClick={() => setStageFilter("KNOCKOUT")}
        >
          Eliminatorias
        </button>
        <button
          type="button"
          className={`btn btn-ghost${stageFilter === "" ? " active-filter" : ""}`}
          onClick={() => setStageFilter("")}
        >
          Todos
        </button>
      </div>

      {error && <div className="alert alert-error">{error}</div>}

      {loading && (
        <div className="panel-card empty-state">
          <strong>Cargando…</strong>
        </div>
      )}

      {!loading && matches.length === 0 && (
        <div className="panel-card empty-state">
          <strong>Sin partidos este día</strong>
          <p>Prueba otra fecha o cambia el filtro de fase.</p>
        </div>
      )}

      <div className="match-grid">
        {!loading &&
          matches.map((match) => (
            <PredictionMatchCard
              key={match.id}
              match={match}
              readOnly={!token}
              onSaved={token ? loadCalendar : undefined}
            />
          ))}
      </div>
    </>
  );
}
