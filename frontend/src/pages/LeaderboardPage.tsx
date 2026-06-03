import { useEffect, useState } from "react";
import { api } from "../lib/api";
import { getUser } from "../lib/auth";

interface LeaderRow {
  user_id: number;
  email: string;
  display_name?: string | null;
  amount_paid?: number;
  total_points: number;
  exact_scores: number;
  qualified_correct: number;
  knockout_advancing: number;
  late_stage_points: number;
}

const fmt = new Intl.NumberFormat("es-CO", {
  style: "currency",
  currency: "COP",
  maximumFractionDigits: 0
});

export function LeaderboardPage() {
  const [rows, setRows] = useState<LeaderRow[]>([]);
  const [loading, setLoading] = useState(true);
  const me = getUser();

  useEffect(() => {
    api<LeaderRow[]>("/leaderboard")
      .then(setRows)
      .catch(() => setRows([]))
      .finally(() => setLoading(false));
  }, []);

  const totalRecaudo = rows.reduce((sum, r) => sum + Number(r.amount_paid ?? 0), 0);
  const premio = totalRecaudo * 0.7;
  const primero = premio * 0.5;
  const segundo = premio * 0.3;
  const tercero = premio * 0.2;

  return (
    <>
      <h1 className="page-title">Ranking</h1>
      <p className="page-subtitle">
        Tabla general acumulada. En empate: marcadores exactos → clasificados → equipos en fases finales →
        puntos en semis/final.
      </p>

      {!loading && premio > 0 && (
        <div className="prize-pool-banner">
          <div className="prize-pool-item prize-pool-item--highlight">
            <span className="prize-pool-label">Bote (70%)</span>
            <span className="prize-pool-value">{fmt.format(premio)}</span>
          </div>
          <div className="prize-pool-divider" />
          <div className="prize-pool-item">
            <span className="prize-pool-label">1° lugar (50%)</span>
            <span className="prize-pool-value prize-pool-value--gold">{fmt.format(primero)}</span>
          </div>
          <div className="prize-pool-divider" />
          <div className="prize-pool-item">
            <span className="prize-pool-label">2° lugar (30%)</span>
            <span className="prize-pool-value prize-pool-value--silver">{fmt.format(segundo)}</span>
          </div>
          <div className="prize-pool-divider" />
          <div className="prize-pool-item">
            <span className="prize-pool-label">3° lugar (20%)</span>
            <span className="prize-pool-value prize-pool-value--bronze">{fmt.format(tercero)}</span>
          </div>
        </div>
      )}

      <div className="panel-card">
        {loading ? (
          <div className="empty-state">
            <strong>Cargando…</strong>
          </div>
        ) : rows.length === 0 ? (
          <div className="empty-state">
            <strong>Sin puntuaciones aún</strong>
          </div>
        ) : (
          <div style={{ overflowX: "auto" }}>
            <table className="data-table">
              <thead>
                <tr>
                  <th>Pos</th>
                  <th>Jugador</th>
                  <th>Pts</th>
                  <th title="Desempate 1">Exactos</th>
                  <th title="Desempate 2">Clasif.</th>
                  <th title="Desempate 3">KO</th>
                  <th title="Desempate 4">Semis+Final</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((row, index) => (
                  <tr key={row.user_id}>
                    <td>
                      <span className={`rank-pill${index < 3 ? " top" : ""}`}>{index + 1}</span>
                    </td>
                    <td>
                      {row.display_name || row.email}
                      {Number(row.user_id) === me?.id && (
                        <span className="badge badge-finished" style={{ marginLeft: 8 }}>
                          Tú
                        </span>
                      )}
                    </td>
                    <td>
                      <strong style={{ fontFamily: "var(--font-serif)", fontSize: "1.15rem" }}>
                        {row.total_points}
                      </strong>
                    </td>
                    <td>{row.exact_scores}</td>
                    <td>{row.qualified_correct}</td>
                    <td>{row.knockout_advancing}</td>
                    <td>{row.late_stage_points}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </>
  );
}
