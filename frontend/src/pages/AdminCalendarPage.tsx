import { useCallback, useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { AdminSubnav } from "../components/AdminSubnav";
import { DateNavigator } from "../components/DateNavigator";
import { MatchParticipantsPanel } from "../components/MatchParticipantsPanel";
import { TeamFlag } from "../components/TeamFlag";
import { api } from "../lib/api";
import { adminMatchStatusClass } from "../lib/matchStatus";
import { nextRoundLabel } from "../lib/knockoutAdvancing";

interface DateRow {
  match_date: string;
  match_count: number;
}

interface CalendarMatch {
  id: number | string;
  stage?: string;
  roundKey?: string | null;
  status: string;
  startsAt: string;
  roundLabel: string | null;
  matchday: number | null;
  groupName: string | null;
  homeTeamId: number;
  homeTeamName: string;
  homeTeamLogoUrl?: string | null;
  awayTeamId: number;
  awayTeamName: string;
  awayTeamLogoUrl?: string | null;
  homeScore: number | null;
  awayScore: number | null;
}

type ResultFilter = "all" | "pending" | "finished" | "live";

function isFinished(status: string): boolean {
  return status === "FINISHED";
}

function isPendingResult(status: string): boolean {
  return status !== "FINISHED";
}

export function AdminCalendarPage() {
  const [selectedDate, setSelectedDate] = useState("2026-06-11");
  const [dates, setDates] = useState<DateRow[]>([]);
  const [matches, setMatches] = useState<CalendarMatch[]>([]);
  const [loading, setLoading] = useState(false);
  const [resultFilter, setResultFilter] = useState<ResultFilter>("all");

  useEffect(() => {
    api<DateRow[]>("/matches/dates")
      .then((rows) => {
        setDates(rows);
        const keys = rows.map((d) => String(d.match_date).slice(0, 10));
        const preferred = keys.find((k) => k.startsWith("2026-06")) ?? keys[0];
        if (preferred) setSelectedDate(preferred);
      })
      .catch(() => undefined);
  }, []);

  const loadCalendar = useCallback(async () => {
    setLoading(true);
    try {
      const data = await api<{ matches: CalendarMatch[] }>(`/admin/calendar?date=${selectedDate}`);
      setMatches(data.matches);
    } catch {
      setMatches([]);
    } finally {
      setLoading(false);
    }
  }, [selectedDate]);

  useEffect(() => {
    setResultFilter("all");
    loadCalendar();
  }, [loadCalendar]);

  const counts = useMemo(
    () => ({
      all: matches.length,
      finished: matches.filter((m) => isFinished(m.status)).length,
      pending: matches.filter((m) => isPendingResult(m.status) && m.status !== "LIVE").length,
      live: matches.filter((m) => m.status === "LIVE").length
    }),
    [matches]
  );

  const sortedMatches = useMemo(() => {
    const order = (s: string) => (s === "FINISHED" ? 0 : s === "LIVE" ? 1 : 2);
    return [...matches].sort((a, b) => order(a.status) - order(b.status));
  }, [matches]);

  const filteredMatches = useMemo(() => {
    switch (resultFilter) {
      case "finished":
        return sortedMatches.filter((m) => isFinished(m.status));
      case "pending":
        return sortedMatches.filter((m) => isPendingResult(m.status) && m.status !== "LIVE");
      case "live":
        return sortedMatches.filter((m) => m.status === "LIVE");
      default:
        return sortedMatches;
    }
  }, [sortedMatches, resultFilter]);

  return (
    <>
      <AdminSubnav />
      <h1 className="page-title">Calendario y resultados</h1>
      <p className="page-subtitle">
        Registra el marcador oficial y finaliza cada partido. Los puntos y las predicciones de cada participante se
        ven al expandir el detalle. Se actualiza la tabla en <Link to="/standings">Grupos</Link> y el{" "}
        <Link to="/leaderboard">Ranking</Link>.
      </p>

      <DateNavigator selectedDate={selectedDate} onChange={setSelectedDate} dates={dates} />

      {!loading && matches.length > 0 && (
        <div className="filter-row admin-results-filters">
          <button
            type="button"
            className={`btn btn-ghost${resultFilter === "all" ? " active-filter" : ""}`}
            onClick={() => setResultFilter("all")}
          >
            Todos ({counts.all})
          </button>
          <button
            type="button"
            className={`btn btn-ghost${resultFilter === "pending" ? " active-filter" : ""}`}
            onClick={() => setResultFilter("pending")}
          >
            Sin finalizar ({counts.pending})
          </button>
          <button
            type="button"
            className={`btn btn-ghost${resultFilter === "finished" ? " active-filter" : ""}`}
            onClick={() => setResultFilter("finished")}
          >
            Finalizados ({counts.finished})
          </button>
          {counts.live > 0 && (
            <button
              type="button"
              className={`btn btn-ghost${resultFilter === "live" ? " active-filter" : ""}`}
              onClick={() => setResultFilter("live")}
            >
              En vivo ({counts.live})
            </button>
          )}
        </div>
      )}

      {!loading && matches.length > 0 && (
        <div className="admin-results-legend" aria-hidden="true">
          <span className="admin-results-legend-title">Estado del partido</span>
          <span className="admin-results-legend-item">
            <span className="admin-results-legend-swatch admin-results-legend-swatch--done" />
            Esmeralda = finalizado
          </span>
          <span className="admin-results-legend-item">
            <span className="admin-results-legend-swatch admin-results-legend-swatch--pending" />
            Gris = pendiente de resultado
          </span>
          <span className="admin-results-legend-item">
            <span className="admin-results-legend-swatch admin-results-legend-swatch--live" />
            Naranja = en vivo
          </span>
        </div>
      )}

      {loading && (
        <div className="panel-card empty-state">
          <strong>Cargando…</strong>
        </div>
      )}

      {!loading && matches.length === 0 && (
        <div className="panel-card empty-state">
          <strong>Sin partidos este día</strong>
        </div>
      )}

      {!loading && matches.length > 0 && filteredMatches.length === 0 && (
        <div className="panel-card empty-state">
          <strong>Ningún partido en este filtro</strong>
          <p style={{ marginTop: "0.5rem" }}>
            Prueba otro filtro o pulsa <em>Todos</em> para ver los {counts.all} partidos del día.
          </p>
        </div>
      )}

      <div className="admin-match-list">
        {filteredMatches.map((match) => (
          <AdminMatchCard key={match.id} match={match} onSaved={loadCalendar} />
        ))}
      </div>
    </>
  );
}

function AdminMatchCard({ match, onSaved }: { match: CalendarMatch; onSaved: () => void }) {
  const [simHome, setSimHome] = useState(match.homeScore ?? 0);
  const [simAway, setSimAway] = useState(match.awayScore ?? 0);
  const [penaltyWinnerId, setPenaltyWinnerId] = useState<number | "">("");
  const [savingResult, setSavingResult] = useState(false);
  const [localMsg, setLocalMsg] = useState("");
  const [showParticipants, setShowParticipants] = useState(true);

  const isKnockout = match.stage === "KNOCKOUT";
  const isDraw = simHome === simAway;
  const nextLabel = nextRoundLabel(match.roundKey);

  useEffect(() => {
    setSimHome(match.homeScore ?? 0);
    setSimAway(match.awayScore ?? 0);
    setPenaltyWinnerId("");
  }, [match]);

  async function saveOfficialResult() {
    if (isKnockout && isDraw && !penaltyWinnerId) {
      setLocalMsg("En empate indica el ganador en penales (quién pasa de ronda)");
      return;
    }
    setSavingResult(true);
    setLocalMsg("");
    try {
      const winnerTeamId = !isDraw
        ? simHome > simAway
          ? match.homeTeamId
          : match.awayTeamId
        : penaltyWinnerId !== ""
          ? Number(penaltyWinnerId)
          : null;
      await api(`/admin/matches/${Number(match.id)}/result`, {
        method: "PATCH",
        body: JSON.stringify({
          status: "FINISHED",
          home_score: simHome,
          away_score: simAway,
          ...(winnerTeamId != null ? { winner_team_id: winnerTeamId } : {})
        })
      });
      setLocalMsg("Partido finalizado: puntos, ranking y tablas de grupo actualizados");
      setShowParticipants(true);
      onSaved();
    } catch (e) {
      setLocalMsg((e as Error).message);
    } finally {
      setSavingResult(false);
    }
  }

  return (
    <article className={`panel-card admin-match-card${adminMatchStatusClass(match.status)}`}>
      <div className="admin-match-header">
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
      </div>
      <p className="admin-match-meta">
        {match.groupName} · J{match.matchday} · {new Date(match.startsAt).toLocaleString("es-ES")}
        {match.status === "FINISHED" && <span className="badge badge-finished"> Finalizado</span>}
      </p>

      <div className="admin-match-block admin-match-block--result admin-match-block--solo">
        <h4>Resultado oficial</h4>
        <p className="admin-block-hint">
          Introduce el marcador final y finaliza el partido. Esto calcula puntos para todos los que predijeron y
          actualiza el grupo y el ranking.
        </p>
        <div className="score-inputs">
          <input
            className="input"
            type="number"
            min={0}
            value={simHome}
            onChange={(e) => setSimHome(Number(e.target.value))}
          />
          <span className="score-sep">:</span>
          <input
            className="input"
            type="number"
            min={0}
            value={simAway}
            onChange={(e) => setSimAway(Number(e.target.value))}
          />
        </div>
        {isKnockout && isDraw && (
          <div className="field" style={{ marginTop: "0.75rem" }}>
            <label>Ganador en penales (pasa a {nextLabel})</label>
            <select
              className="select"
              value={penaltyWinnerId}
              onChange={(e) => setPenaltyWinnerId(e.target.value ? Number(e.target.value) : "")}
            >
              <option value="">Elegir equipo…</option>
              <option value={match.homeTeamId}>{match.homeTeamName}</option>
              <option value={match.awayTeamId}>{match.awayTeamName}</option>
            </select>
          </div>
        )}
        {isKnockout && !isDraw && simHome !== simAway && (
          <p className="admin-block-hint" style={{ marginTop: "0.5rem" }}>
            Pasa a {nextLabel}:{" "}
            <strong>{simHome > simAway ? match.homeTeamName : match.awayTeamName}</strong>
          </p>
        )}
        <button
          type="button"
          className="btn btn-primary btn-block"
          disabled={savingResult}
          onClick={saveOfficialResult}
          style={{ marginTop: "0.75rem" }}
        >
          {savingResult ? "Procesando…" : "Finalizar partido y calcular puntos"}
        </button>
        {localMsg && <small className="admin-local-msg">{localMsg}</small>}
      </div>

      <div style={{ marginTop: "1rem" }}>
        <button
          type="button"
          className="btn btn-ghost btn-block"
          onClick={() => setShowParticipants((v) => !v)}
        >
          {showParticipants ? "Ocultar participantes" : "Ver predicciones y puntos de todos"}
        </button>
        <MatchParticipantsPanel
          matchId={Number(match.id)}
          open={showParticipants}
          refreshKey={`${match.status}-${match.homeScore}-${match.awayScore}`}
        />
      </div>
    </article>
  );
}
