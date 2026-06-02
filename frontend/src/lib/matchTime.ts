/** Hora de inicio en hora local de la sede (no UTC del navegador). */
export function formatKickoffLocal(match: {
  kickoff_time_local?: string | null;
  starts_at: string;
}): string {
  if (match.kickoff_time_local) {
    const [hh, mm] = match.kickoff_time_local.split(":");
    return `${hh}:${mm}`;
  }
  return new Date(match.starts_at).toLocaleTimeString("es-ES", {
    hour: "2-digit",
    minute: "2-digit"
  });
}

export function formatCalendarDateYmd(ymd: string): string {
  const [y, m, d] = ymd.split("-").map(Number);
  return new Date(Date.UTC(y, m - 1, d)).toLocaleDateString("es-ES", {
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "UTC"
  });
}

export function formatPredictionWindowRange(openDate: string, closeDate: string): string {
  return `${formatCalendarDateYmd(openDate)} – ${formatCalendarDateYmd(closeDate)}`;
}

export function formatPredictionLock(iso: string | undefined | null): string {
  if (!iso) return "—";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "—";
  return d.toLocaleString("es-ES", {
    day: "numeric",
    month: "numeric",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit"
  });
}
