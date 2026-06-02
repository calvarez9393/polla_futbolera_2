/** Fecha de calendario: día local del partido en la sede (no día UTC). */
export function matchCalendarDateSql(alias = "m"): string {
  return `COALESCE(${alias}.calendar_date, (${alias}.starts_at AT TIME ZONE 'UTC')::date)`;
}

/** Normaliza fechas de PostgreSQL/JS a YYYY-MM-DD. */
export function parseCalendarYmd(value: unknown): string {
  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    const y = value.getUTCFullYear();
    const m = String(value.getUTCMonth() + 1).padStart(2, "0");
    const d = String(value.getUTCDate()).padStart(2, "0");
    return `${y}-${m}-${d}`;
  }
  const s = String(value);
  const iso = s.match(/^(\d{4}-\d{2}-\d{2})/);
  if (iso) return iso[1];
  const parsed = new Date(s);
  if (!Number.isNaN(parsed.getTime())) {
    return parsed.toISOString().slice(0, 10);
  }
  throw new Error(`Fecha de calendario inválida: ${s}`);
}

/** source_id único por jornada para EXPERT_DAY (YYYYMMDD). */
export function ymdToExpertDaySourceId(ymd: string): number {
  const id = Number(ymd.replace(/-/g, ""));
  if (!Number.isFinite(id) || id <= 0) {
    throw new Error(`No se pudo convertir la fecha ${ymd} a identificador de jornada`);
  }
  return id;
}

/** SQL: partidos de Fase 1 (grupos + dieciseisavos). */
export function phase1MatchSql(alias = "m"): string {
  return `(${alias}.stage = 'GROUP' OR ${alias}.round_key = 'R16')`;
}
