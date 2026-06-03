import { useCallback, useEffect, useState } from "react";
import type { FormEvent } from "react";
import { Link } from "react-router-dom";
import { AdminSubnav } from "../components/AdminSubnav";
import { PageTitle, SectionTitle } from "../components/InfoModal";
import { AdminR16BracketEditor } from "../components/AdminR16BracketEditor";
import { TeamFlag } from "../components/TeamFlag";
import { api } from "../lib/api";

interface Team {
  id: number;
  name: string;
  logoUrl?: string | null;
  groupName: string;
}

interface OfficialGroupStanding {
  groupId: number;
  groupName: string;
  teams: Array<{
    teamId: number;
    name: string;
    logoUrl?: string | null;
    rank: number;
    points: number;
    played: number;
    goalDiff: number;
    goalsFor: number;
  }>;
}

interface BonusPicks {
  championTeamId?: number | null;
  runnerUpTeamId?: number | null;
  thirdPlaceTeamId?: number | null;
  semifinalistTeamIds?: number[];
  finalistTeamIds?: number[];
  topScorer?: string | null;
  topAssister?: string | null;
}

export function AdminOfficialPage() {
  const [allTeams, setAllTeams] = useState<Team[]>([]);
  const [selected, setSelected] = useState<Set<number>>(new Set());
  const [bonuses, setBonuses] = useState<BonusPicks>({
    semifinalistTeamIds: [],
    finalistTeamIds: []
  });
  const [message, setMessage] = useState("");
  const [isError, setIsError] = useState(false);
  const [loading, setLoading] = useState(true);
  const [officialStandings, setOfficialStandings] = useState<OfficialGroupStanding[]>([]);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const ctx = await api<{
        qualifiedTeamIds: number[];
        bonuses: BonusPicks;
        groups: Array<{ name: string; teams: Team[] }>;
      }>("/admin/official/context");
      setAllTeams(ctx.groups.flatMap((g) => g.teams));
      setSelected(new Set(ctx.qualifiedTeamIds));
      setBonuses({
        championTeamId: ctx.bonuses.championTeamId ?? null,
        runnerUpTeamId: ctx.bonuses.runnerUpTeamId ?? null,
        thirdPlaceTeamId: ctx.bonuses.thirdPlaceTeamId ?? null,
        semifinalistTeamIds: ctx.bonuses.semifinalistTeamIds ?? [],
        finalistTeamIds: ctx.bonuses.finalistTeamIds ?? [],
        topScorer: ctx.bonuses.topScorer ?? "",
        topAssister: ctx.bonuses.topAssister ?? ""
      });
      const standings = await api<{ groups: OfficialGroupStanding[] }>("/admin/official/standings");
      setOfficialStandings(standings.groups);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load().catch(() => undefined);
  }, [load]);

  function toggleTeam(id: number) {
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else if (next.size < 24) next.add(id);
      return next;
    });
  }

  function selectTop2FromStandings() {
    const ids: number[] = [];
    for (const g of officialStandings) {
      for (const t of g.teams) {
        if (t.rank <= 2) ids.push(t.teamId);
      }
    }
    setSelected(new Set(ids));
  }

  function toggleSemi(id: number) {
    setBonuses((b) => {
      const list = [...(b.semifinalistTeamIds ?? [])];
      const i = list.indexOf(id);
      if (i >= 0) list.splice(i, 1);
      else if (list.length < 4) list.push(id);
      return { ...b, semifinalistTeamIds: list };
    });
  }

  function toggleFinal(id: number) {
    setBonuses((b) => {
      const list = [...(b.finalistTeamIds ?? [])];
      const i = list.indexOf(id);
      if (i >= 0) list.splice(i, 1);
      else if (list.length < 2) list.push(id);
      return { ...b, finalistTeamIds: list };
    });
  }

  async function saveQualifiers(e: FormEvent) {
    e.preventDefault();
    if (selected.size !== 24) {
      setIsError(true);
      setMessage("Debes marcar exactamente 24 equipos clasificados");
      return;
    }
    try {
      await api("/admin/official/qualifiers", {
        method: "PUT",
        body: JSON.stringify({ teamIds: [...selected] })
      });
      setIsError(false);
      setMessage("Clasificados oficiales guardados");
    } catch (err) {
      setIsError(true);
      setMessage((err as Error).message);
    }
  }

  async function saveBonuses(e: FormEvent) {
    e.preventDefault();
    try {
      await api("/admin/official/bonuses", {
        method: "PUT",
        body: JSON.stringify({
          ...bonuses,
          topScorer: bonuses.topScorer?.trim() || null,
          topAssister: bonuses.topAssister?.trim() || null
        })
      });
      setIsError(false);
      setMessage("Resultados oficiales del cuadro guardados");
    } catch (err) {
      setIsError(true);
      setMessage((err as Error).message);
    }
  }

  async function runCalc(kind: string, path: string) {
    try {
      const r = await api<Record<string, number>>(path, { method: "POST" });
      setIsError(false);
      setMessage(`${kind}: ${JSON.stringify(r)}`);
      await load();
    } catch (err) {
      setIsError(true);
      setMessage((err as Error).message);
    }
  }

  return (
    <>
      <AdminSubnav />
      <PageTitle
        helpTitle="Resultados oficiales"
        help={<p>Define los 24 clasificados y el cuadro final. Luego calcula puntos para todos los participantes.</p>}
      >
        Resultados oficiales
      </PageTitle>

      {message && <div className={`alert ${isError ? "alert-error" : "alert-success"}`}>{message}</div>}

      {loading ? (
        <div className="panel-card empty-state">
          <strong>Cargando…</strong>
        </div>
      ) : (
        <>
          <section className="admin-official-phase">
            <header className="admin-official-phase-head admin-official-phase-head--ko">
              <SectionTitle
                title="Eliminatorias — cuadro y cruces"
                className="admin-official-phase-title-row"
                help={
                  <p>
                    Define el cuadro de dieciseisavos (cruces y mejores terceros) y los premios del campeón. Los{" "}
                    <strong>marcadores de cada partido</strong> se cargan en{" "}
                    <Link to="/admin/calendar">Calendario y resultados → Eliminatorias</Link>.
                  </p>
                }
              />
            </header>

            <AdminR16BracketEditor
              onMessage={(msg, err) => {
                setMessage(msg);
                setIsError(err);
              }}
            />

            <form className="panel-card" onSubmit={saveBonuses} style={{ marginBottom: "1.25rem" }}>
              <h3 style={{ fontSize: "1.1rem", marginBottom: "0.75rem" }}>Campeón, final y premios especiales</h3>
              <div className="field">
                <label>Campeón</label>
                <select
                  className="select"
                  value={bonuses.championTeamId ?? ""}
                  onChange={(e) =>
                    setBonuses((b) => ({ ...b, championTeamId: e.target.value ? Number(e.target.value) : null }))
                  }
                >
                  <option value="">—</option>
                  {allTeams.map((t) => (
                    <option key={t.id} value={t.id}>
                      {t.name}
                    </option>
                  ))}
                </select>
              </div>
              <div className="field">
                <label>Subcampeón</label>
                <select
                  className="select"
                  value={bonuses.runnerUpTeamId ?? ""}
                  onChange={(e) =>
                    setBonuses((b) => ({ ...b, runnerUpTeamId: e.target.value ? Number(e.target.value) : null }))
                  }
                >
                  <option value="">—</option>
                  {allTeams.map((t) => (
                    <option key={t.id} value={t.id}>
                      {t.name}
                    </option>
                  ))}
                </select>
              </div>
              <div className="field">
                <label>Tercer puesto</label>
                <select
                  className="select"
                  value={bonuses.thirdPlaceTeamId ?? ""}
                  onChange={(e) =>
                    setBonuses((b) => ({ ...b, thirdPlaceTeamId: e.target.value ? Number(e.target.value) : null }))
                  }
                >
                  <option value="">—</option>
                  {allTeams.map((t) => (
                    <option key={t.id} value={t.id}>
                      {t.name}
                    </option>
                  ))}
                </select>
              </div>
              <p className="admin-block-hint">Semifinalistas (4)</p>
              <div className="qualifier-grid">
                {allTeams.map((t) => (
                  <button
                    key={`s-${t.id}`}
                    type="button"
                    className={`qualifier-chip${bonuses.semifinalistTeamIds?.includes(t.id) ? " qualifier-chip--on" : ""}`}
                    onClick={() => toggleSemi(t.id)}
                  >
                    {t.name}
                  </button>
                ))}
              </div>
              <p className="admin-block-hint" style={{ marginTop: "0.75rem" }}>
                Finalistas (2)
              </p>
              <div className="qualifier-grid">
                {allTeams.map((t) => (
                  <button
                    key={`f-${t.id}`}
                    type="button"
                    className={`qualifier-chip${bonuses.finalistTeamIds?.includes(t.id) ? " qualifier-chip--on" : ""}`}
                    onClick={() => toggleFinal(t.id)}
                  >
                    {t.name}
                  </button>
                ))}
              </div>
              <div className="field" style={{ marginTop: "1rem" }}>
                <label>Goleador del mundial</label>
                <input
                  className="input"
                  value={bonuses.topScorer ?? ""}
                  onChange={(e) => setBonuses((b) => ({ ...b, topScorer: e.target.value }))}
                />
              </div>
              <div className="field">
                <label>Máximo asistidor</label>
                <input
                  className="input"
                  value={bonuses.topAssister ?? ""}
                  onChange={(e) => setBonuses((b) => ({ ...b, topAssister: e.target.value }))}
                />
              </div>
              <button type="submit" className="btn btn-primary" style={{ marginTop: "0.75rem" }}>
                Guardar cuadro oficial
              </button>
              <button
                type="button"
                className="btn btn-ghost"
                style={{ marginLeft: "0.5rem" }}
                onClick={() => runCalc("Cuadro", "/admin/scoring/calculate-bonuses")}
              >
                Calcular puntos cuadro/premios
              </button>
            </form>
          </section>

          <section className="admin-official-phase">
            <header className="admin-official-phase-head">
              <SectionTitle
                title="Fase de grupos — clasificados"
                className="admin-official-phase-title-row"
                help={
                  <p>
                    Los 24 equipos que pasan a eliminatorias según resultados reales de la fase de grupos. Los
                    marcadores de cada partido se cargan en{" "}
                    <Link to="/admin/calendar">Calendario y resultados → Fase de grupos</Link>.
                  </p>
                }
              />
            </header>

          <form className="panel-card" onSubmit={saveQualifiers} style={{ marginBottom: "1.25rem" }}>
            <SectionTitle
              as="h3"
              title="24 clasificados oficiales"
              help={
                <p>
                  Los 24 oficiales son el top 2 de cada grupo según resultados reales finalizados. Puedes calcularlos
                  automáticamente o ajustar manualmente si hace falta.
                </p>
              }
            />
            <div className="admin-qualifiers-toolbar">
              <button
                type="button"
                className="btn btn-primary"
                onClick={async () => {
                  try {
                    const r = await api<{ count: number }>("/admin/scoring/sync-official-qualifiers-from-results", {
                      method: "POST"
                    });
                    setIsError(false);
                    setMessage(`Clasificados desde tablas reales: ${r.count} equipos`);
                    await load();
                  } catch (err) {
                    setIsError(true);
                    setMessage((err as Error).message);
                  }
                }}
              >
                Tomar top 2 por grupo (resultados reales)
              </button>
              <button
                type="button"
                className="btn btn-ghost"
                onClick={selectTop2FromStandings}
                disabled={officialStandings.length === 0}
              >
                Marcar top 2 en tablas (vista previa)
              </button>
              <button
                type="button"
                className="btn btn-ghost"
                onClick={() =>
                  runCalc("Sincronizar predicciones de usuarios", "/admin/scoring/sync-qualifiers-from-predictions")
                }
              >
                Recalcular clasificados de todos (desde sus predicciones)
              </button>
            </div>

            <p className="admin-block-hint admin-qualifiers-meta">
              Seleccionados para puntaje: <strong>{selected.size} / 24</strong>. Haz clic en una fila para
              incluir o quitar un equipo. Borde verde = clasificado oficial guardado.
            </p>

            <div className="admin-qualifiers-legend" aria-hidden="true">
              <span className="admin-qualifiers-legend-item">
                <span className="admin-qualifiers-legend-swatch admin-qualifiers-legend-swatch--direct" />
                Top 2 del grupo
              </span>
              <span className="admin-qualifiers-legend-item">
                <span className="admin-qualifiers-legend-swatch admin-qualifiers-legend-swatch--third" />
                3º (mejores terceros)
              </span>
              <span className="admin-qualifiers-legend-item">
                <span className="admin-qualifiers-legend-swatch admin-qualifiers-legend-swatch--picked" />
                Oficial seleccionado
              </span>
            </div>

            {officialStandings.length === 0 ? (
              <div className="panel-card empty-state" style={{ marginTop: "1rem" }}>
                <strong>Sin tablas oficiales</strong>
                <p style={{ marginTop: "0.5rem" }}>
                  Finaliza partidos de la fase de grupos para ver las tablas aquí.
                </p>
              </div>
            ) : (
              <div className="admin-qualifiers-tables">
                {officialStandings.map((g) => (
                  <section key={g.groupId} className="panel-card qualifier-group-card admin-group-table-card">
                    <h3 className="admin-group-table-title">Grupo {g.groupName}</h3>
                    <div className="table-scroll">
                      <table className="data-table qualifier-table admin-official-table">
                        <thead>
                          <tr>
                            <th>#</th>
                            <th>Equipo</th>
                            <th>PJ</th>
                            <th>Pts</th>
                            <th>DG</th>
                            <th>GF</th>
                          </tr>
                        </thead>
                        <tbody>
                          {g.teams.map((t) => {
                            const isPicked = selected.has(t.teamId);
                            const isTop2 = t.rank <= 2;
                            const isThird = t.rank === 3;
                            return (
                              <tr
                                key={t.teamId}
                                className={[
                                  "admin-official-row",
                                  isTop2 ? "qualifier-row--direct" : "",
                                  isThird ? "qualifier-row--third" : "",
                                  isPicked ? "qualifier-row--official admin-official-row--picked" : ""
                                ]
                                  .filter(Boolean)
                                  .join(" ")}
                                onClick={() => toggleTeam(t.teamId)}
                                role="button"
                                tabIndex={0}
                                onKeyDown={(e) => {
                                  if (e.key === "Enter" || e.key === " ") {
                                    e.preventDefault();
                                    toggleTeam(t.teamId);
                                  }
                                }}
                              >
                                <td>{t.rank}</td>
                                <td>
                                  <span className="qualifier-team-cell">
                                    <TeamFlag name={t.name} logoUrl={t.logoUrl} size="sm" />
                                    <span>{t.name}</span>
                                    {isTop2 && <span className="badge badge-live">Top 2</span>}
                                    {isPicked && !isTop2 && (
                                      <span className="badge badge-scheduled">Oficial</span>
                                    )}
                                  </span>
                                </td>
                                <td>{t.played}</td>
                                <td>{t.points}</td>
                                <td>{t.goalDiff > 0 ? `+${t.goalDiff}` : t.goalDiff}</td>
                                <td>{t.goalsFor}</td>
                              </tr>
                            );
                          })}
                        </tbody>
                      </table>
                    </div>
                  </section>
                ))}
              </div>
            )}
            <button type="submit" className="btn btn-primary" style={{ marginTop: "1rem" }} disabled={selected.size !== 24}>
              Guardar clasificados oficiales
            </button>
            <button
              type="button"
              className="btn btn-ghost"
              style={{ marginTop: "0.5rem", marginLeft: "0.5rem" }}
              onClick={() => runCalc("Clasificados", "/admin/scoring/calculate-qualifiers")}
            >
              Calcular puntos clasificados
            </button>
          </form>

          <section className="panel-card">
            <h3 style={{ fontSize: "1.1rem", marginBottom: "0.5rem" }}>Bonos Fase 1 (grupos)</h3>
            <p className="admin-block-hint">
              <strong>Experto del día</strong> (+10): por cada jornada con todos los partidos de Fase 1 finalizados
              (grupos + dieciseisavos), si un usuario acertó el 1X2 en todos ese día. No depende de los 24
              clasificados ni del cuadro de 32.
            </p>
            <p className="admin-block-hint" style={{ marginTop: "0.5rem" }}>
              <strong>Invicto</strong> (+15): 10 resultados seguidos en Fase 1. <strong>Maestro de grupo</strong> (+5):
              acertar los 2 clasificados oficiales de un grupo (24 equipos = top 2 × 12 grupos, distinto del cuadro de
              dieciseisavos con 32 plazas).
            </p>
            <div className="admin-qualifiers-toolbar" style={{ marginTop: "0.75rem" }}>
              <button
                type="button"
                className="btn btn-primary"
                onClick={() =>
                  runCalc("Experto del día", "/admin/scoring/calculate-expert-day-bonuses")
                }
              >
                Calcular experto del día (jornadas)
              </button>
              <button
                type="button"
                className="btn btn-ghost"
                onClick={() => runCalc("Invicto y maestro", "/admin/scoring/calculate-phase1-bonuses")}
              >
                Calcular invicto y maestro de grupo
              </button>
            </div>
          </section>
          </section>
        </>
      )}
    </>
  );
}
