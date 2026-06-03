import { formatDisplayDate, shiftDate } from "../lib/date";

export interface MatchDateRow {
  match_date: string;
  match_count: number;
  pending_count?: number;
  finished_count?: number;
}

interface DateNavigatorProps {
  selectedDate: string;
  onChange: (date: string) => void;
  dates?: MatchDateRow[];
  /** Muestra cuántos resultados faltan por cargar en cada fecha (admin). */
  showPendingCounts?: boolean;
}

function dateKey(row: MatchDateRow): string {
  return String(row.match_date).slice(0, 10);
}

export function DateNavigator({ selectedDate, onChange, dates = [], showPendingCounts = false }: DateNavigatorProps) {
  const selectedRow = dates.find((d) => dateKey(d) === selectedDate);
  const selectedPending = selectedRow?.pending_count ?? 0;
  const selectedTotal = selectedRow?.match_count ?? 0;

  return (
    <div className="date-nav panel-card">
      <div className="date-nav-controls">
        <button type="button" className="btn btn-ghost" onClick={() => onChange(shiftDate(selectedDate, -1))}>
          ← Día anterior
        </button>
        <input
          className="input date-input"
          type="date"
          value={selectedDate}
          onChange={(e) => onChange(e.target.value)}
        />
        <button type="button" className="btn btn-ghost" onClick={() => onChange(shiftDate(selectedDate, 1))}>
          Día siguiente →
        </button>
      </div>
      <p className="date-nav-label">{formatDisplayDate(selectedDate)}</p>
      {showPendingCounts && selectedTotal > 0 && (
        <p
          className={`date-nav-pending-summary${selectedPending > 0 ? " date-nav-pending-summary--warn" : " date-nav-pending-summary--ok"}`}
        >
          {selectedPending > 0 ? (
            <>
              <strong>{selectedPending}</strong> de {selectedTotal} partidos sin resultado cargado
              {selectedRow?.finished_count != null && selectedRow.finished_count > 0
                ? ` · ${selectedRow.finished_count} listo${selectedRow.finished_count === 1 ? "" : "s"}`
                : ""}
            </>
          ) : (
            <>Todos los resultados de esta fecha están cargados ({selectedTotal} partidos)</>
          )}
        </p>
      )}
      {dates.length > 0 && (
        <div className="date-chips">
          {dates.map((d) => {
            const key = dateKey(d);
            const pending = d.pending_count ?? 0;
            const isActive = key === selectedDate;
            const allDone = showPendingCounts && pending === 0;
            return (
              <button
                key={key}
                type="button"
                className={`date-chip${isActive ? " active" : ""}${showPendingCounts && pending > 0 ? " date-chip--pending" : ""}${showPendingCounts && allDone ? " date-chip--complete" : ""}`}
                onClick={() => onChange(key)}
                title={
                  showPendingCounts
                    ? pending > 0
                      ? `${pending} partido(s) sin resultado en esta fecha`
                      : "Todos los resultados cargados"
                    : undefined
                }
              >
                <span className="date-chip-date">{key}</span>
                <span className="date-chip-meta">
                  {d.match_count} partido{d.match_count === 1 ? "" : "s"}
                  {showPendingCounts &&
                    (pending > 0 ? (
                      <span className="date-chip-pending-badge">
                        · {pending} sin resultado
                      </span>
                    ) : (
                      <span className="date-chip-done-badge"> · completo</span>
                    ))}
                </span>
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}
