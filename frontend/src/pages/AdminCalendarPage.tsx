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
import { nextRoundLabel } from "../lib/knockoutAdvancing";

type AdminPhase = "group" | "knockout";

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

function countMatches(matches: CalendarMatch[]) {
  return {
    all: matches.length,
    finished: matches.filter((m) => isFinished(m.status)).length,
    pending: matches.filter((m) => isPendingResult(m.status) && m.status !== "LIVE").length,
    live: matches.filter((m) => m.status === "LIVE").length
  };
}

function sortByStatus(matches: CalendarMatch[]): CalendarMatch[] {
  const order = (s: string) => (s === "FINISHED" ? 0 : s === "LIVE" ? 1 : 2);
  return [...matches].sort((a, b) => order(a.status) - order(b.status));
}

function filterMatches(matches: CalendarMatch[], resultFilter: ResultFilter): CalendarMatch[] {
  const sorted = sortByStatus(matches);
  switch (resultFilter) {
    case "finished":
      return sorted.filter((m) => isFinished(m.status));
    case "pending":
      return sorted.filter((m) => isPendingResult(m.status) && m.status !== "LIVE");
    case "live":
      return sorted.filter((m) => m.status === "LIVE");
    default:
      return sorted;
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

  const loadGroupCalendar = useCallback(async () => {
    setLoadingGroup(true);
    try {
      const data = await api<{ matches: CalendarMatch[] }>(`/admin/calendar?date=${selectedDate}`);
      setGroupMatches(data.matches);
    } catch {
      setGroupMatches([]);
    } finally {
      setLoadingGroup(false);
    }
  }, [selectedDate]);

  const loadKnockout = useCallback(async () => {
    setLoadingKo(true);
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
    loadGroupCalendar();
    loadDates();
  }, [loadGroupCalendar, loadDates]);

  const onKnockoutSaved = useCallback(() => {
    loadKnockout();
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
      setLocalMsg("Partido finalizado: puntos, ranking y tablas actualizados");
      setShowParticipants(true);
      onSaved();
    } catch (e) {
      setLocalMsg((e as Error).message);
    } finally {
      setSavingResult(false);
    }
  }

  const metaParts: ReactNode[] = [];
  if (isKnockout && match.roundLabel) {
    metaParts.push(<span key="round">{match.roundLabel}</span>);
  } else if (match.groupName) {
    metaParts.push(<span key="grp">{match.groupName}</span>);
    if (match.matchday != null) metaParts.push(<span key="j">J{match.matchday}</span>);
  }
  metaParts.push(
    <span key="when">{new Date(match.startsAt).toLocaleString("es-ES")}</span>
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
      </p>

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
