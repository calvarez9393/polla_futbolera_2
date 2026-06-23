import { useCallback, useEffect, useMemo, useState } from "react";
import { AdminSubnav } from "../components/AdminSubnav";
import { PageTitle } from "../components/InfoModal";
import { api } from "../lib/api";

interface RoundCell {
  filled: number;
  total: number;
}

interface KnockoutUserCompletion {
  userId: number;
  email: string;
  displayName: string | null;
  perRound: Record<string, RoundCell>;
  totalFilled: number;
  totalMatches: number;
  complete: boolean;
}

interface KnockoutCompletion {
  roundOrder: string[];
  roundLabels: Record<string, string>;
  roundTotals: Record<string, number>;
  totalMatches: number;
  users: KnockoutUserCompletion[];
}

function cellClass(cell: RoundCell): string {
  if (cell.total === 0) return "";
  if (cell.filled >= cell.total) return "ko-cell ko-cell--ok";
  if (cell.filled === 0) return "ko-cell ko-cell--none";
  return "ko-cell ko-cell--partial";
}

function statusBadge(user: KnockoutUserCompletion) {
  if (user.complete) return <span className="badge badge-finished">Completo</span>;
  if (user.totalFilled === 0) return <span className="badge badge-live">Sin llenar</span>;
  return <span className="badge badge-scheduled">Incompleto</span>;
}

export function AdminKnockoutCompletionPage() {
  const [data, setData] = useState<KnockoutCompletion | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [onlyIncomplete, setOnlyIncomplete] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await api<KnockoutCompletion>("/admin/knockout-completion");
      setData(res);
      setError("");
    } catch (e) {
      setError((e as Error).message);
      setData(null);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load().catch(() => undefined);
  }, [load]);

  const completedCount = useMemo(
    () => data?.users.filter((u) => u.complete).length ?? 0,
    [data]
  );

  const visibleUsers = useMemo(() => {
    if (!data) return [];
    return onlyIncomplete ? data.users.filter((u) => !u.complete) : data.users;
  }, [data, onlyIncomplete]);

  return (
    <>
      <PageTitle
        helpTitle="Quién llenó las eliminatorias"
        help={
          <p>
            Detalle por ronda y total de cuántos cruces de eliminatoria llenó cada usuario activo. Útil para detectar
            a quienes no completaron sus predicciones antes del cierre. <strong>Completo</strong> = llenó todos los
            cruces; <strong>Sin llenar</strong> = no registró ninguno.
          </p>
        }
      >
        Eliminatorias — llenado
      </PageTitle>

      <AdminSubnav />

      {error && <div className="alert alert-error">{error}</div>}
      {loading && (
        <div className="panel-card empty-state">
          <strong>Cargando…</strong>
        </div>
      )}

      {!loading && data && (
        <section className="panel-card">
          <div className="admin-users-toolbar">
            <p className="admin-ko-callout-stats" style={{ margin: 0 }}>
              {completedCount}/{data.users.length} usuarios completaron las eliminatorias ·{" "}
              {data.totalMatches} cruces por persona
            </p>
            <div className="admin-users-actions">
              <label className="admin-users-toggle">
                <input
                  type="checkbox"
                  checked={onlyIncomplete}
                  onChange={(e) => setOnlyIncomplete(e.target.checked)}
                />
                Solo incompletos
              </label>
            </div>
          </div>

          {data.users.length === 0 ? (
            <p className="admin-block-hint">No hay usuarios activos.</p>
          ) : data.totalMatches === 0 ? (
            <p className="admin-block-hint">
              Aún no hay partidos de eliminatoria importados para el torneo activo.
            </p>
          ) : (
            <div className="table-scroll">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Usuario</th>
                    {data.roundOrder.map((k) => (
                      <th key={k} style={{ textAlign: "center" }}>
                        {data.roundLabels[k] ?? k}
                      </th>
                    ))}
                    <th style={{ textAlign: "center" }}>Total</th>
                    <th style={{ textAlign: "center" }}>Estado</th>
                  </tr>
                </thead>
                <tbody>
                  {visibleUsers.map((u) => (
                    <tr key={u.userId}>
                      <td>{u.displayName || u.email}</td>
                      {data.roundOrder.map((k) => {
                        const cell = u.perRound[k] ?? { filled: 0, total: data.roundTotals[k] ?? 0 };
                        return (
                          <td key={k} style={{ textAlign: "center" }}>
                            <span className={cellClass(cell)}>
                              {cell.filled}/{cell.total}
                            </span>
                          </td>
                        );
                      })}
                      <td style={{ textAlign: "center" }}>
                        <strong>
                          {u.totalFilled}/{u.totalMatches}
                        </strong>
                      </td>
                      <td style={{ textAlign: "center" }}>{statusBadge(u)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {onlyIncomplete && visibleUsers.length === 0 && data.users.length > 0 && (
            <p className="admin-block-hint" style={{ marginTop: "0.75rem" }}>
              🎉 Todos los usuarios completaron sus eliminatorias.
            </p>
          )}
        </section>
      )}
    </>
  );
}
