import { useCallback, useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { PageTitle, SectionTitle } from "../components/InfoModal";
import { PredictionsSubnav } from "../components/PredictionsSubnav";
import { PointsChips } from "../components/PointsChips";
import { TeamFlag } from "../components/TeamFlag";
import { api } from "../lib/api";

interface TeamInfo {
  id: number;
  name: string;
  shortName: string;
  logoUrl?: string | null;
  groupName: string;
}

interface GroupRow {
  rank: number;
  teamId: number;
  team?: TeamInfo;
  points: number;
  goalDiff: number;
  goalsFor: number;
  played: number;
  qualifies: boolean;
  isThird: boolean;
  officialQualified: boolean;
}

interface GroupBlock {
  groupId: number;
  groupName: string;
  rows: GroupRow[];
}

interface ThirdRanked {
  teamId: number;
  groupName: string;
  points: number;
  goalDiff: number;
  goalsFor: number;
  isBestThird?: boolean;
  team?: TeamInfo;
}

interface QualifiersData {
  predictedMatches: number;
  expectedGroupMatches: number;
  directQualifiers: number[];
  groups: GroupBlock[];
  bestThirds: ThirdRanked[];
  allThirdsRanked: ThirdRanked[];
  earnedPoints: number | null;
  earnedBreakdown: Record<string, number> | null;
  officialQualifiedCount: number;
}

export function QualifiersPage() {
  const [data, setData] = useState<QualifiersData | null>(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const load = useCallback(async () => {
    const res = await api<QualifiersData>("/predictions/me/qualifiers");
    setData(res);
  }, []);

  useEffect(() => {
    setLoading(true);
    load()
      .catch(() => undefined)
      .finally(() => setLoading(false));
  }, [load]);

  async function recompute() {
    setRefreshing(true);
    try {
      const res = await api<QualifiersData>("/predictions/me/qualifiers/recompute", { method: "POST" });
      setData(res);
    } finally {
      setRefreshing(false);
    }
  }

  const progress =
    data && data.expectedGroupMatches > 0
      ? Math.round((data.predictedMatches / data.expectedGroupMatches) * 100)
      : 0;

  return (
    <>
      <PageTitle
        helpTitle="Cuadro de 32 — Fase 1"
        help={
          <p>
            Simula quiénes llegan a los dieciseisavos: <strong>32 equipos</strong> (top 2 de cada grupo + 8 mejores
            terceros), con la misma lógica FIFA y tus marcadores de grupos. Los puntos de clasificados en la polla son
            por los <strong>24 directos</strong> (4 pts por acierto cuando el admin publique los oficiales).
          </p>
        }
      >
        Cuadro de 32 — Fase 1
      </PageTitle>

      <PredictionsSubnav />

      {loading && (
        <div className="panel-card empty-state">
          <strong>Cargando…</strong>
        </div>
      )}

      {!loading && data && (
        <>
          <div className="panel-card" style={{ marginBottom: "1rem" }}>
            <p>
              Partidos de grupos con marcador predicho:{" "}
              <strong>
                {data.predictedMatches} / {data.expectedGroupMatches}
              </strong>{" "}
              ({progress}%)
            </p>
            <p style={{ marginTop: "0.5rem" }}>
              Equipos en tu cuadro de 32:{" "}
              <strong>
                {data.directQualifiers.length + data.bestThirds.length}
              </strong>{" "}
              ({data.directQualifiers.length} directos + {data.bestThirds.length} mejores terceros)
            </p>
            <button
              type="button"
              className="btn btn-ghost"
              style={{ marginTop: "0.75rem" }}
              disabled={refreshing}
              onClick={recompute}
            >
              {refreshing ? "Recalculando…" : "Recalcular cuadro de 32"}
            </button>
            {data.earnedPoints != null && (
              <div style={{ marginTop: "0.75rem" }}>
                <PointsChips breakdown={data.earnedBreakdown} totalPoints={data.earnedPoints} />
              </div>
            )}
            {data.officialQualifiedCount > 0 && (
              <p className="admin-block-hint" style={{ marginTop: "0.5rem" }}>
                Directos oficiales para puntaje: {data.officialQualifiedCount}/24 — filas con borde verde coinciden
                con el resultado real.
              </p>
            )}
          </div>

          <section className="panel-card" style={{ marginBottom: "1rem" }}>
            <SectionTitle
              title="Dieciseisavos oficiales"
              help={
                <p>
                  El cuadro de 16 avos lo publica el administrador con los resultados reales. Tus cruces simulados se
                  ven al predecir en Eliminatorias.
                </p>
              }
            />
            <Link to="/predictions/r16" className="btn btn-primary">
              Ver cuadro oficial
            </Link>
          </section>

          {data.bestThirds.length > 0 && (
            <section className="panel-card" style={{ marginBottom: "1rem" }}>
              <h2 style={{ fontSize: "1rem", marginBottom: "0.75rem" }}>8 mejores terceros (simulación FIFA)</h2>
              <ol className="best-thirds-list">
                {data.bestThirds.map((t, i) => (
                  <li key={t.teamId}>
                    <span className="best-thirds-rank">{i + 1}.</span>
                    {t.team && <TeamFlag name={t.team.name} logoUrl={t.team.logoUrl} size="sm" />}
                    <span>
                      {t.team?.name ?? `Equipo ${t.teamId}`} — Grupo {t.groupName} ({t.points} pts, DG {t.goalDiff})
                    </span>
                  </li>
                ))}
              </ol>
            </section>
          )}

          {data.groups.map((g) => (
            <section key={g.groupId} className="panel-card qualifier-group-card" style={{ marginBottom: "1rem" }}>
              <h2 style={{ fontSize: "1rem", marginBottom: "0.75rem" }}>Grupo {g.groupName}</h2>
              <div className="table-scroll">
                <table className="data-table qualifier-table">
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
                    {g.rows.map((row) => (
                      <tr
                        key={row.teamId}
                        className={[
                          row.qualifies ? "qualifier-row--direct" : "",
                          row.isThird ? "qualifier-row--third" : "",
                          row.officialQualified ? "qualifier-row--official" : ""
                        ]
                          .filter(Boolean)
                          .join(" ")}
                      >
                        <td>{row.rank}</td>
                        <td>
                          {row.team && (
                            <span className="qualifier-team-cell">
                              <TeamFlag name={row.team.name} logoUrl={row.team.logoUrl} size="sm" />
                              {row.team.name}
                              {row.qualifies && <span className="badge badge-live">Al cuadro</span>}
                            </span>
                          )}
                        </td>
                        <td>{row.played}</td>
                        <td>{row.points}</td>
                        <td>{row.goalDiff > 0 ? `+${row.goalDiff}` : row.goalDiff}</td>
                        <td>{row.goalsFor}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </section>
          ))}
        </>
      )}
    </>
  );
}
