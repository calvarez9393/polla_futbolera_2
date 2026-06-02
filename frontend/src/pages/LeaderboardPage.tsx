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

  return (
    <>
      <h1 className="page-title">Ranking</h1>
      <p className="page-subtitle">
        Tabla general acumulada. En empate: marcadores exactos → clasificados → equipos en fases finales →
        puntos en semis/final.
      </p>

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
                  {me?.role === "ADMIN" && <th>Pagado</th>}
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
                    {me?.role === "ADMIN" && (
                      <td>
                        {new Intl.NumberFormat("es-CO", {
                          style: "currency",
                          currency: "COP",
                          maximumFractionDigits: 0
                        }).format(Number(row.amount_paid ?? 0))}
                      </td>
                    )}
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
