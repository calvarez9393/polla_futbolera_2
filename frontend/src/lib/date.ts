export function toDateInputValue(date: Date): string {
  return date.toISOString().slice(0, 10);
}

/** Fecha local del navegador en YYYY-MM-DD (evita desfase UTC en Colombia, etc.). */
export function localTodayYmd(): string {
  const d = new Date();
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

/** Elige hoy si hay partidos; si no, la fecha del calendario más cercana a hoy. */
export function pickNearestCalendarDate(keys: string[]): string {
  if (keys.length === 0) return localTodayYmd();
  const today = localTodayYmd();
  if (keys.includes(today)) return today;
  const todayMs = Date.parse(`${today}T12:00:00`);
  let best = keys[0];
  let bestDiff = Infinity;
  for (const key of keys) {
    const diff = Math.abs(Date.parse(`${key}T12:00:00`) - todayMs);
    if (diff < bestDiff) {
      bestDiff = diff;
      best = key;
    }
  }
  return best;
}

export function formatDisplayDate(isoDate: string): string {
  const [y, m, d] = isoDate.split("-").map(Number);
  const date = new Date(Date.UTC(y, m - 1, d));
  return date.toLocaleDateString("es-ES", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "UTC"
  });
}

export function shiftDate(isoDate: string, days: number): string {
  const [y, m, d] = isoDate.split("-").map(Number);
  const date = new Date(Date.UTC(y, m - 1, d));
  date.setUTCDate(date.getUTCDate() + days);
  return toDateInputValue(date);
}
