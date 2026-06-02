import { formatDisplayDate, shiftDate } from "../lib/date";

interface DateNavigatorProps {
  selectedDate: string;
  onChange: (date: string) => void;
  dates?: { match_date: string; match_count: number }[];
}

export function DateNavigator({ selectedDate, onChange, dates = [] }: DateNavigatorProps) {
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
      {dates.length > 0 && (
        <div className="date-chips">
          {dates.map((d) => {
            const dateKey = String(d.match_date).slice(0, 10);
            return (
            <button
              key={dateKey}
              type="button"
              className={`date-chip${dateKey === selectedDate ? " active" : ""}`}
              onClick={() => onChange(dateKey)}
            >
              {dateKey} ({d.match_count})
            </button>
            );
          })}
        </div>
      )}
    </div>
  );
}
