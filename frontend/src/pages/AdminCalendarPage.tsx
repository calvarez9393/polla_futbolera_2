import { useCallback, useEffect, useMemo, useState } from "react";
import type { ReactNode } from "react";
import { Link } from "react-router-dom";
import { AdminSubnav } from "../components/AdminSubnav";
import { ExclusiveAccordion } from "../components/ExclusiveAccordion";
import { InfoModal, PageTitle, SectionTitle } from "../components/InfoModal";
import { DateNavigator, type MatchDateRow } from "../components/DateNavigator";
import { MatchParticipantsPanel } from "../components/MatchParticipantsPanel";
import { TeamFlag } from "../components/TeamFlag";
import { api } from "../lib/api";
import { groupKnockoutByRound } from "../lib/knockoutRounds";
import { adminMatchStatusClass } from "../lib/matchStatus";
import { formatCalendarDateYmd } from "../lib/matchTime";
import { nextRoundLabel } from "../lib/knockoutAdvancing";

type AdminPhase = "group" | "knockout";

interface CalendarMatch {
  id: number | string;
  stage?: string;
  roundKey?: string | null;
  status: string;
  startsAt: string;
  calendarDate?: string | null;
  kickoffTimeLocal?: string | null;
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
  winnerTeamId?: number | null;
  scoreMultiplier?: number | null;
}

type ResultFilter = "all" | "pending" | "finished" | "live";

function isFinished(status: string): boolean {
  return status === "FINISHED";
}

function isPendingResult(status: string): boolean {
  return status !== "FINISHED";
}

function countMatches(matches: CalendarMatch[]) {
  return {
    all: matches.length,
    finished: matches.filter((m) => isFinished(m.status)).length,
    pending: matches.filter((m) => isPendingResult(m.status) && m.status !== "LIVE").length,
    live: matches.filter((m) => m.status === "LIVE").length
  };
}

/** Mantiene el orden del calendario: así las tarjetas no se mueven al finalizar un partido. */
function filterMatches(matches: CalendarMatch[], resultFilter: ResultFilter): CalendarMatch[] {
  switch (resultFilter) {
    case "finished":
      return matches.filter((m) => isFinished(m.status));
    case "pending":
      return matches.filter((m) => isPendingResult(m.status) && m.status !== "LIVE");
    case "live":
      return matches.filter((m) => m.status === "LIVE");
    default:
      return matches;
  }
}

function ResultFilters({
  counts,
  resultFilter,
  onFilter
}: {
  counts: ReturnType<typeof countMatches>;
  resultFilter: ResultFilter;
  onFilter: (f: ResultFilter) => void;
}) {
  if (counts.all === 0) return null;
  return (
    <div className="filter-row admin-results-filters">
      <button
        type="button"
        className={`btn btn-ghost${resultFilter === "all" ? " active-filter" : ""}`}
        onClick={() => onFilter("all")}
      >
        Todos ({counts.all})
      </button>
      <button
        type="button"
        className={`btn btn-ghost${resultFilter === "pending" ? " active-filter" : ""}`}
        onClick={() => onFilter("pending")}
      >
        Sin finalizar ({counts.pending})
      </button>
      <button
        type="button"
        className={`btn btn-ghost${resultFilter === "finished" ? " active-filter" : ""}`}
        onClick={() => onFilter("finished")}
      >
        Finalizados ({counts.finished})
      </button>
      {counts.live > 0 && (
        <button
          type="button"
          className={`btn btn-ghost${resultFilter === "live" ? " active-filter" : ""}`}
          onClick={() => onFilter("live")}
        >
          En vivo ({counts.live})
        </button>
      )}
    </div>
  );
}

function StatusLegend() {
  return (
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
  );
}

function MatchList({
  matches,
  resultFilter,
  onFilter,
  onSaved,
  emptyMessage
}: {
  matches: CalendarMatch[];
  resultFilter: ResultFilter;
  onFilter: (f: ResultFilter) => void;
  onSaved: () => void;
  emptyMessage?: string;
}) {
  const counts = useMemo(() => countMatches(matches), [matches]);
  const filtered = useMemo(() => filterMatches(matches, resultFilter), [matches, resultFilter]);

  return (
    <>
      <ResultFilters counts={counts} resultFilter={resultFilter} onFilter={onFilter} />
      {matches.length > 0 && <StatusLegend />}
      {matches.length > 0 && filtered.length === 0 && (
        <div className="panel-card empty-state">
          <strong>Ningún partido en este filtro</strong>
          <p style={{ marginTop: "0.5rem" }}>
            Prueba otro filtro o pulsa <em>Todos</em> para ver los {counts.all} partidos.
          </p>
        </div>
      )}
      {matches.length === 0 && emptyMessage && (
        <div className="panel-card empty-state">
          <strong>{emptyMessage}</strong>
        </div>
      )}
      <div className="admin-match-list">
        {filtered.map((match) => (
          <AdminMatchCard key={match.id} match={match} onSaved={onSaved} />
        ))}
      </div>
    </>
  );
}

export function AdminCalendarPage() {
  const [phase, setPhase] = useState<AdminPhase>("group");
  const [selectedDate, setSelectedDate] = useState("2026-06-11");
  const [dates, setDates] = useState<MatchDateRow[]>([]);
  const [groupMatches, setGroupMatches] = useState<CalendarMatch[]>([]);
  const [koMatches, setKoMatches] = useState<CalendarMatch[]>([]);
  const [loadingGroup, setLoadingGroup] = useState(false);
  const [loadingKo, setLoadingKo] = useState(false);
  const [groupFilter, setGroupFilter] = useState<ResultFilter>("all");
  const [koFilter, setKoFilter] = useState<ResultFilter>("all");

  const loadDates = useCallback(async () => {
    try {
      const rows = await api<MatchDateRow[]>("/matches/dates?stage=GROUP");
      setDates(rows);
      return rows;
    } catch {
      setDates([]);
      return [];
    }
  }, []);

  useEffect(() => {
    loadDates().then((rows) => {
      const keys = rows.map((d) => String(d.match_date).slice(0, 10));
      const preferred = keys.find((k) => k.startsWith("2026-06")) ?? keys[0];
      if (preferred) setSelectedDate(preferred);
    });
  }, [loadDates]);

  // silent: refresca datos sin desmontar la lista (mantiene scroll y ronda abierta tras guardar).
  const loadGroupCalendar = useCallback(
    async (opts?: { silent?: boolean }) => {
      if (!opts?.silent) setLoadingGroup(true);
      try {
        const data = await api<{ matches: CalendarMatch[] }>(
          `/admin/calendar?date=${selectedDate}`
        );
        setGroupMatches(data.matches);
      } catch {
        setGroupMatches([]);
      } finally {
        setLoadingGroup(false);
      }
    },
    [selectedDate]
  );

  const loadKnockout = useCallback(async (opts?: { silent?: boolean }) => {
    if (!opts?.silent) setLoadingKo(true);
    try {
      const data = await api<{ matches: CalendarMatch[] }>("/admin/calendar/knockout");
      setKoMatches(data.matches);
    } catch {
      setKoMatches([]);
    } finally {
      setLoadingKo(false);
    }
  }, []);

  useEffect(() => {
    setGroupFilter("all");
    loadGroupCalendar();
  }, [loadGroupCalendar]);

  useEffect(() => {
    loadKnockout();
  }, [loadKnockout]);

  const onGroupSaved = useCallback(() => {
    loadGroupCalendar({ silent: true });
    loadDates();
  }, [loadGroupCalendar, loadDates]);

  const onKnockoutSaved = useCallback(() => {
    loadKnockout({ silent: true });
  }, [loadKnockout]);

  const koCounts = useMemo(() => countMatches(koMatches), [koMatches]);
  const koRounds = useMemo(() => groupKnockoutByRound(koMatches), [koMatches]);
  const filteredKoByRound = useMemo(() => {
    const filtered = filterMatches(koMatches, koFilter);
    const ids = new Set(filtered.map((m) => m.id));
    return koRounds
      .map((round) => ({
        ...round,
        matches: round.matches.filter((m) => ids.has(m.id))
      }))
      .filter((round) => round.matches.length > 0);
  }, [koMatches, koFilter, koRounds]);

  function switchPhase(next: AdminPhase) {
    setPhase(next);
    if (next === "knockout") loadKnockout();
  }

  return (
    <>
      <AdminSubnav />
      <PageTitle
        helpTitle="Calendario y resultados"
        help={
          <p>Fase de grupos por fecha; eliminatorias por ronda. Registra marcadores y finaliza cada partido.</p>
        }
      >
        Calendario y resultados
      </PageTitle>

      <div className="admin-phase-tabs-head">
        <span className="admin-phase-tabs-label">Fases del torneo</span>
        <InfoModal title="Fases del torneo">
          <p>
            <strong>Fase de grupos:</strong> partidos por jornada y fecha.
          </p>
          <p>
            <strong>Eliminatorias:</strong> cruces por ronda (octavos, cuartos, semis, final). Carga marcador y
            ganador en penales si aplica.
          </p>
        </InfoModal>
      </div>

      <div className="admin-phase-tabs" role="tablist" aria-label="Fase del torneo">
        <button
          type="button"
          role="tab"
          aria-selected={phase === "group"}
          className={`admin-phase-tab${phase === "group" ? " admin-phase-tab--active" : ""}`}
          onClick={() => switchPhase("group")}
        >
          <span className="admin-phase-tab-title">Fase de grupos</span>
          <span className="admin-phase-tab-desc">Partidos por jornada y fecha</span>
        </button>
        <button
          type="button"
          role="tab"
          aria-selected={phase === "knockout"}
          className={`admin-phase-tab admin-phase-tab--knockout${phase === "knockout" ? " admin-phase-tab--active" : ""}`}
          onClick={() => switchPhase("knockout")}
        >
          <span className="admin-phase-tab-title">Eliminatorias</span>
          <span className="admin-phase-tab-desc">
            {koMatches.length === 0
              ? "Importa el cuadro en Configuración"
              : koCounts.pending > 0
                ? `${koCounts.pending} resultado(s) por cargar`
                : "Cuadro al día"}
          </span>
        </button>
      </div>

      {phase === "group" && (
        <section className="admin-phase-panel admin-phase-panel--group" aria-label="Fase de grupos">
          <DateNavigator
            selectedDate={selectedDate}
            onChange={setSelectedDate}
            dates={dates}
            showPendingCounts
          />

          {loadingGroup && (
            <div className="panel-card empty-state">
              <strong>Cargando…</strong>
            </div>
          )}

          {!loadingGroup && groupMatches.length === 0 && (
            <div className="panel-card empty-state">
              <strong>Sin partidos de grupos este día</strong>
            </div>
          )}

          {!loadingGroup && groupMatches.length > 0 && (
            <MatchList
              matches={groupMatches}
              resultFilter={groupFilter}
              onFilter={setGroupFilter}
              onSaved={onGroupSaved}
            />
          )}
        </section>
      )}

      {phase === "knockout" && (
        <section className="admin-phase-panel admin-phase-panel--knockout" aria-label="Eliminatorias">
          <div className="admin-ko-callout panel-card">
            <SectionTitle
              title="Datos de eliminatorias"
              className="admin-ko-callout-title-row"
              help={
                <p>
                  Aquí cargas el <strong>marcador oficial</strong> de cada cruce. Si hay empate, indica el ganador en
                  penales. Para el <strong>cuadro de dieciseisavos</strong> (cruces y mejores terceros) usa{" "}
                  <Link to="/admin/official">Oficiales y bonos</Link>.
                </p>
              }
            />
            {koMatches.length > 0 && (
              <p
                className={`admin-ko-callout-stats${koCounts.pending > 0 ? " admin-ko-callout-stats--warn" : " admin-ko-callout-stats--ok"}`}
              >
                {koCounts.pending > 0 ? (
                  <>
                    <strong>{koCounts.pending}</strong> de {koCounts.all} partidos eliminatorios sin resultado
                    cargado
                  </>
                ) : (
                  <>Todos los resultados eliminatorios están cargados ({koCounts.all} partidos)</>
                )}
              </p>
            )}
          </div>

          {loadingKo && (
            <div className="panel-card empty-state">
              <strong>Cargando eliminatorias…</strong>
            </div>
          )}

          {!loadingKo && koMatches.length === 0 && (
            <div className="panel-card empty-state">
              <strong>Sin partidos eliminatorios</strong>
              <p style={{ marginTop: "0.5rem" }}>
                Ve a <Link to="/admin">Configuración</Link> → Importar cuadro eliminatorio.
              </p>
            </div>
          )}

          {!loadingKo && koMatches.length > 0 && (
            <>
              <ResultFilters counts={koCounts} resultFilter={koFilter} onFilter={setKoFilter} />
              <StatusLegend />

              {filteredKoByRound.length === 0 && (
                <div className="panel-card empty-state">
                  <strong>Ningún partido en este filtro</strong>
                </div>
              )}

              {filteredKoByRound.length > 0 && (
                <ExclusiveAccordion
                  className="admin-ko-accordion"
                  items={filteredKoByRound.map((round) => {
                    const roundCounts = countMatches(round.matches);
                    return {
                      id: round.roundKey,
                      title: round.title,
                      meta: (
                        <>
                          {round.matches.length} partido{round.matches.length === 1 ? "" : "s"}
                          {roundCounts.pending > 0 && (
                            <span className="admin-ko-round-pending">
                              {" "}
                              · {roundCounts.pending} sin resultado
                            </span>
                          )}
                          {roundCounts.pending === 0 && roundCounts.all > 0 && (
                            <span className="admin-ko-round-done"> · completo</span>
                          )}
                        </>
                      ),
                      badge:
                        roundCounts.pending > 0 ? (
                          <span className="badge badge-scheduled admin-ko-round-badge">
                            {roundCounts.pending} pendiente{roundCounts.pending === 1 ? "" : "s"}
                          </span>
                        ) : null,
                      children: (
                        <div className="admin-match-list">
                          {round.matches.map((match) => (
                            <AdminMatchCard
                              key={match.id}
                              match={match}
                              onSaved={onKnockoutSaved}
                              highlightKnockout
                            />
                          ))}
                        </div>
                      )
                    };
                  })}
                />
              )}
            </>
          )}
        </section>
      )}
    </>
  );
}

function AdminMatchCard({
  match,
  onSaved,
  highlightKnockout = false
}: {
  match: CalendarMatch;
  onSaved: () => void;
  highlightKnockout?: boolean;
}) {
  const initialDate = match.calendarDate?.slice(0, 10) ?? match.startsAt.slice(0, 10);
  const initialTime =
    match.kickoffTimeLocal?.slice(0, 5) ?? new Date(match.startsAt).toISOString().slice(11, 16);

  const initialMultiplier = match.scoreMultiplier ?? 1;

  const [simHome, setSimHome] = useState(match.homeScore ?? 0);
  const [simAway, setSimAway] = useState(match.awayScore ?? 0);
  const [penaltyWinnerId, setPenaltyWinnerId] = useState<number | "">(match.winnerTeamId ?? "");
  const [multiplier, setMultiplier] = useState(initialMultiplier);
  const [multiplierPassword, setMultiplierPassword] = useState("");
  const [savingResult, setSavingResult] = useState(false);
  const [localMsg, setLocalMsg] = useState("");
  const [showDelete, setShowDelete] = useState(false);
  const [deletePassword, setDeletePassword] = useState("");
  const [deleting, setDeleting] = useState(false);
  const [deleteMsg, setDeleteMsg] = useState("");
  const [showParticipants, setShowParticipants] = useState(true);
  const [showSchedule, setShowSchedule] = useState(false);
  const [schedDate, setSchedDate] = useState(initialDate);
  const [schedTime, setSchedTime] = useState(initialTime);
  const [savingSchedule, setSavingSchedule] = useState(false);
  const [schedMsg, setSchedMsg] = useState("");

  const isKnockout = match.stage === "KNOCKOUT";
  const isDraw = simHome === simAway;
  const nextLabel = nextRoundLabel(match.roundKey);
  const multiplierChanged = Math.abs(multiplier - initialMultiplier) > 1e-9;

  useEffect(() => {
    setSimHome(match.homeScore ?? 0);
    setSimAway(match.awayScore ?? 0);
    setPenaltyWinnerId(match.winnerTeamId ?? "");
    setMultiplier(match.scoreMultiplier ?? 1);
    setMultiplierPassword("");
    setSchedDate(initialDate);
    setSchedTime(initialTime);
    setSchedMsg("");
    setShowDelete(false);
    setDeletePassword("");
    setDeleteMsg("");
  }, [match, initialDate, initialTime]);

  async function saveSchedule() {
    if (!schedDate || !schedTime) {
      setSchedMsg("Indica fecha y hora");
      return;
    }
    setSavingSchedule(true);
    setSchedMsg("");
    try {
      await api(`/admin/matches/${Number(match.id)}/schedule`, {
        method: "PATCH",
        body: JSON.stringify({ calendarDate: schedDate, kickoffTimeLocal: schedTime })
      });
      setSchedMsg("Fecha actualizada");
      onSaved();
    } catch (e) {
      setSchedMsg((e as Error).message);
    } finally {
      setSavingSchedule(false);
    }
  }

  async function saveOfficialResult() {
    if (isKnockout && isDraw && !penaltyWinnerId) {
      setLocalMsg("En empate indica el ganador en penales (quién pasa de ronda)");
      return;
    }
    const multiplierChanged = Math.abs(multiplier - initialMultiplier) > 1e-9;
    if (multiplierChanged && !multiplierPassword) {
      setLocalMsg("Escribe la clave para cambiar el multiplicador de puntos");
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
          score_multiplier: multiplier,
          ...(winnerTeamId != null ? { winner_team_id: winnerTeamId } : {}),
          ...(multiplierChanged ? { password: multiplierPassword } : {})
        })
      });
      setLocalMsg("Partido finalizado: puntos, ranking y tablas actualizados");
      setMultiplierPassword("");
      setShowParticipants(true);
      onSaved();
    } catch (e) {
      setLocalMsg((e as Error).message);
    } finally {
      setSavingResult(false);
    }
  }

  async function deleteResult() {
    if (!deletePassword) {
      setDeleteMsg("Escribe la clave para borrar");
      return;
    }
    setDeleting(true);
    setDeleteMsg("");
    try {
      await api(`/admin/matches/${Number(match.id)}/result`, {
        method: "DELETE",
        body: JSON.stringify({ password: deletePassword })
      });
      setDeleteMsg("Resultado y puntos borrados");
      setDeletePassword("");
      setShowDelete(false);
      onSaved();
    } catch (e) {
      setDeleteMsg((e as Error).message);
    } finally {
      setDeleting(false);
    }
  }

  const metaParts: ReactNode[] = [];
  if (isKnockout && match.roundLabel) {
    metaParts.push(<span key="round">{match.roundLabel}</span>);
  } else if (match.groupName) {
    metaParts.push(<span key="grp">{match.groupName}</span>);
    if (match.matchday != null) metaParts.push(<span key="j">J{match.matchday}</span>);
  }
  // Hora de la sede (igual que el editor): evita el corrimiento de día por el huso del navegador.
  metaParts.push(
    <span key="when">
      {formatCalendarDateYmd(initialDate)} · {initialTime} h (hora sede)
    </span>
  );

  return (
    <article
      className={`panel-card admin-match-card${adminMatchStatusClass(match.status)}${highlightKnockout ? " admin-match-card--knockout" : ""}`}
    >
      {isKnockout && (
        <span className="admin-match-phase-badge admin-match-phase-badge--ko">Eliminatoria</span>
      )}
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
        {metaParts.reduce<ReactNode[]>((acc, part, i) => {
          if (i > 0) acc.push(" · ");
          acc.push(part);
          return acc;
        }, [])}
        {match.status === "FINISHED" && <span className="badge badge-finished"> Finalizado</span>}
        {initialMultiplier !== 1 && (
          <span className="badge badge-multiplier"> Puntos ×{initialMultiplier}</span>
        )}
      </p>

      <div className="admin-match-block" style={{ marginBottom: "1rem" }}>
        <button
          type="button"
          className="btn btn-ghost btn-block"
          onClick={() => setShowSchedule((v) => !v)}
        >
          {showSchedule ? "Ocultar cambio de fecha" : "Cambiar fecha y hora"}
        </button>
        {showSchedule && (
          <>
            <SectionTitle
              as="h3"
              title="Fecha y hora del partido"
              help={
                <p>
                  Fecha y hora <strong>locales de la sede</strong>. Al guardar se recalcula el día en el
                  calendario y el cierre de predicciones del partido.
                </p>
              }
            />
            <div className="score-inputs">
              <input
                className="input"
                type="date"
                value={schedDate}
                onChange={(e) => setSchedDate(e.target.value)}
              />
              <input
                className="input"
                type="time"
                value={schedTime}
                onChange={(e) => setSchedTime(e.target.value)}
              />
            </div>
            <button
              type="button"
              className="btn btn-primary btn-block"
              disabled={savingSchedule}
              onClick={saveSchedule}
              style={{ marginTop: "0.75rem" }}
            >
              {savingSchedule ? "Guardando…" : "Guardar nueva fecha"}
            </button>
            {schedMsg && <small className="admin-local-msg">{schedMsg}</small>}
          </>
        )}
      </div>

      <div className="admin-match-block admin-match-block--result admin-match-block--solo">
        <SectionTitle
          as="h3"
          title="Resultado oficial"
          help={
            <p>
              Introduce el marcador final y finaliza el partido. Esto calcula puntos para todos los que predijeron.
            </p>
          }
        />
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
        <div className="field" style={{ marginTop: "0.75rem" }}>
          <label>Multiplicador de puntos (todos los participantes)</label>
          <input
            className="input"
            type="number"
            min={0}
            max={100}
            step={0.5}
            value={multiplier}
            onChange={(e) => setMultiplier(Number(e.target.value))}
          />
          <small className="admin-block-hint">
            Los puntos de este partido se multiplican por este factor (1 = normal). Cambiarlo exige la
            clave.
          </small>
        </div>
        {multiplierChanged && (
          <div className="field" style={{ marginTop: "0.5rem" }}>
            <label>Clave para cambiar el multiplicador</label>
            <input
              className="input"
              type="password"
              autoComplete="off"
              placeholder="Clave"
              value={multiplierPassword}
              onChange={(e) => setMultiplierPassword(e.target.value)}
            />
          </div>
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

        {match.status === "FINISHED" && (
          <div className="admin-match-delete" style={{ marginTop: "1rem" }}>
            {!showDelete ? (
              <button
                type="button"
                className="btn btn-danger btn-block"
                onClick={() => {
                  setShowDelete(true);
                  setDeleteMsg("");
                }}
              >
                Borrar resultado
              </button>
            ) : (
              <div className="panel-card" style={{ padding: "0.85rem" }}>
                <label>Escribe la clave para borrar el resultado y sus puntos</label>
                <input
                  className="input"
                  type="password"
                  autoComplete="off"
                  placeholder="Clave"
                  value={deletePassword}
                  onChange={(e) => setDeletePassword(e.target.value)}
                  style={{ marginTop: "0.4rem" }}
                />
                <div className="filter-row" style={{ marginTop: "0.6rem" }}>
                  <button
                    type="button"
                    className="btn btn-danger"
                    disabled={deleting}
                    onClick={deleteResult}
                  >
                    {deleting ? "Borrando…" : "Confirmar borrado"}
                  </button>
                  <button
                    type="button"
                    className="btn btn-ghost"
                    disabled={deleting}
                    onClick={() => {
                      setShowDelete(false);
                      setDeletePassword("");
                      setDeleteMsg("");
                    }}
                  >
                    Cancelar
                  </button>
                </div>
              </div>
            )}
            {deleteMsg && <small className="admin-local-msg">{deleteMsg}</small>}
          </div>
        )}
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
