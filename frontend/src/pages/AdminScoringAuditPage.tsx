import { useCallback, useEffect, useState } from "react";
import { AdminSubnav } from "../components/AdminSubnav";
import { PageTitle } from "../components/InfoModal";
import { api } from "../lib/api";

interface AuditUserRow {
  userId: number;
  code: string;
  displayName: string | null;
  isActive: boolean;
  role: string;
  byDate: Record<string, number>;
  entriesByDate: Record<string, number>;
  total: number;
}

interface AuditResponse {
  dates: string[];
  rows: AuditUserRow[];
  columnTotals: Record<string, number>;
  grandTotal: number;
  generatedAt: string;
}

const numberFmt = new Intl.NumberFormat("es-CO");

/** Fecha corta para los encabezados de columna (ej. "11 jun"). ymd = YYYY-MM-DD. */
function shortDate(ymd: string): string {
  const [y, m, d] = ymd.split("-").map(Number);
  return new Date(Date.UTC(y, m - 1, d)).toLocaleDateString("es-ES", {
    day: "numeric",
    month: "short",
    timeZone: "UTC"
  });
}

/** Fecha larga para el title/tooltip del encabezado. */
function longDate(ymd: string): string {
  const [y, m, d] = ymd.split("-").map(Number);
  return new Date(Date.UTC(y, m - 1, d)).toLocaleDateString("es-ES", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "UTC"
  });
}

export function AdminScoringAuditPage() {
  const [data, setData] = useState<AuditResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const res = await api<AuditResponse>("/admin/scoring-audit");
      setData(res);
    } catch (e) {
      setError((e as Error).message);
      setData(null);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const dates = data?.dates ?? [];
  // Verificación cruzada: la suma de los totales por columna debe igualar el total general.
  const sumOfColumns = dates.reduce((acc, d) => acc + (data?.columnTotals[d] ?? 0), 0);

  return (
    <>
      <AdminSubnav />
      <PageTitle
        helpTitle="Auditoría de puntos"
        help={
          <>
            <p>
              Muestra cuántos puntos se le generaron a cada usuario en cada <strong>fecha de generación</strong>{" "}
              (cuándo se calcularon los puntos, no la fecha del partido). La tabla está totalizada por fila
              (usuario), por columna (fecha) y en total general.
            </p>
            <p>
              El total de cada usuario coincide con su total del ranking, así puedes cuadrar la tabla y detectar
              días o usuarios con puntos que no deberían existir.
            </p>
          </>
        }
      >
        Auditoría de puntos por fecha
      </PageTitle>

      {error && <div className="alert alert-error">{error}</div>}

      <section className="panel-card">
        <div className="admin-users-toolbar">
          <div className="audit-summary">
            <div className="audit-stat">
              <b>{data ? numberFmt.format(data.grandTotal) : "—"}</b>
              <span>Puntos totales</span>
            </div>
            <div className="audit-stat">
              <b>{data ? numberFmt.format(data.rows.length) : "—"}</b>
              <span>Usuarios con puntos</span>
            </div>
            <div className="audit-stat">
              <b>{data ? numberFmt.format(dates.length) : "—"}</b>
              <span>Fechas de generación</span>
            </div>
          </div>
          <button type="button" className="btn btn-ghost" onClick={load} disabled={loading}>
            {loading ? "Cargando…" : "Actualizar"}
          </button>
        </div>

        {data && sumOfColumns !== data.grandTotal && (
          <div className="alert alert-error">
            Descuadre: la suma de columnas ({numberFmt.format(sumOfColumns)}) no coincide con el total general (
            {numberFmt.format(data.grandTotal)}).
          </div>
        )}

        {loading ? (
          <p className="empty-state">Cargando…</p>
        ) : !data || data.rows.length === 0 ? (
          <p className="empty-state">Aún no hay puntos generados.</p>
        ) : (
          <div className="table-scroll">
            <table className="data-table audit-table">
              <thead>
                <tr>
                  <th className="audit-user-cell">Usuario</th>
                  {dates.map((d) => (
                    <th key={d} className="audit-num" title={longDate(d)}>
                      {shortDate(d)}
                    </th>
                  ))}
                  <th className="audit-num audit-total-col" title="Total del usuario">
                    Total
                  </th>
                </tr>
              </thead>
              <tbody>
                {data.rows.map((row) => (
                  <tr key={row.userId} className={row.isActive ? "" : "audit-row--inactive"}>
                    <td className="audit-user-cell">
                      <span className="audit-user-name">
                        {row.displayName || row.code}
                        {row.role === "ADMIN" && (
                          <span className="badge badge-scheduled" style={{ marginLeft: 6 }}>
                            Admin
                          </span>
                        )}
                        {!row.isActive && (
                          <span className="badge badge-inactive" style={{ marginLeft: 6 }}>
                            Inactivo
                          </span>
                        )}
                      </span>
                      {row.displayName && <span className="audit-user-code">{row.code}</span>}
                    </td>
                    {dates.map((d) => {
                      const value = row.byDate[d] ?? 0;
                      const entries = row.entriesByDate[d] ?? 0;
                      return (
                        <td
                          key={d}
                          className={`audit-num${value === 0 ? " audit-zero" : ""}`}
                          title={
                            entries > 0
                              ? `${numberFmt.format(value)} pts · ${entries} registro(s) · ${longDate(d)}`
                              : undefined
                          }
                        >
                          {value === 0 ? "·" : numberFmt.format(value)}
                        </td>
                      );
                    })}
                    <td className="audit-num audit-total-col">{numberFmt.format(row.total)}</td>
                  </tr>
                ))}
              </tbody>
              <tfoot>
                <tr>
                  <td className="audit-user-cell">Total por fecha</td>
                  {dates.map((d) => (
                    <td key={d} className="audit-num">
                      {numberFmt.format(data.columnTotals[d] ?? 0)}
                    </td>
                  ))}
                  <td className="audit-num audit-total-col">{numberFmt.format(data.grandTotal)}</td>
                </tr>
              </tfoot>
            </table>
          </div>
        )}
      </section>
    </>
  );
}
