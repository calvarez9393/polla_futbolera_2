import { WC2026_KNOCKOUT_FIXTURES } from "./wc2026KnockoutFixtures.js";

/** Zona horaria de referencia para el calendario sede del Mundial 2026. */
export const KNOCKOUT_PREDICTION_TIMEZONE = "America/New_York";

export interface KnockoutRoundWindow {
  roundKey: string;
  openDate: string;
  closeDate: string;
}

/** Fechas globales configuradas en admin (app_settings). */
export interface KnockoutPredictionConfig {
  openDate: string | null;
  closeDate: string | null;
}

const ROUND_SHORT_LABELS: Record<string, string> = {
  R16: "dieciseisavos",
  R8: "octavos",
  R4: "cuartos de final",
  SF: "semifinales",
  TP3: "tercer puesto",
  F: "la final"
};

let cachedWindows: Map<string, KnockoutRoundWindow> | null = null;

export function getKnockoutRoundWindows(): Map<string, KnockoutRoundWindow> {
  if (!cachedWindows) {
    cachedWindows = new Map();
    for (const fx of WC2026_KNOCKOUT_FIXTURES) {
      const key = fx.roundKey;
      const cur = cachedWindows.get(key);
      if (!cur) {
        cachedWindows.set(key, {
          roundKey: key,
          openDate: fx.dateLocal,
          closeDate: fx.dateLocal
        });
      } else {
        if (fx.dateLocal < cur.openDate) cur.openDate = fx.dateLocal;
        if (fx.dateLocal > cur.closeDate) cur.closeDate = fx.dateLocal;
      }
    }
  }
  return cachedWindows;
}

export function formatVenueCalendarDate(now = new Date()): string {
  return new Intl.DateTimeFormat("en-CA", { timeZone: KNOCKOUT_PREDICTION_TIMEZONE }).format(now);
}

export function getKnockoutFixtureDefaults(): { openDate: string; closeDate: string } {
  const windows = getKnockoutRoundWindows();
  let openDate = "2099-12-31";
  let closeDate = "1970-01-01";
  for (const w of windows.values()) {
    if (w.openDate < openDate) openDate = w.openDate;
    if (w.closeDate > closeDate) closeDate = w.closeDate;
  }
  return { openDate, closeDate };
}

export function getKnockoutRoundWindow(
  roundKey: string | null | undefined
): KnockoutRoundWindow | null {
  if (!roundKey) return null;
  return getKnockoutRoundWindows().get(roundKey.toUpperCase()) ?? null;
}

export function hasAdminKnockoutWindow(config: KnockoutPredictionConfig | null | undefined): boolean {
  return Boolean(config?.openDate || config?.closeDate);
}

/** Ventana efectiva: admin (BD) si está configurada; si no, calendario FIFA por ronda. */
export function resolveEffectiveKnockoutWindow(
  roundKey: string | null | undefined,
  config: KnockoutPredictionConfig | null = null
): KnockoutRoundWindow | null {
  const fixture = getKnockoutRoundWindow(roundKey);
  const defaults = getKnockoutFixtureDefaults();
  const key = roundKey?.toUpperCase() ?? "KO";

  if (hasAdminKnockoutWindow(config)) {
    return {
      roundKey: key,
      openDate: config!.openDate ?? defaults.openDate,
      closeDate: config!.closeDate ?? defaults.closeDate
    };
  }

  return fixture;
}

export function isKnockoutRoundOpenForPredictions(
  roundKey: string | null | undefined,
  now = new Date(),
  config: KnockoutPredictionConfig | null = null
): boolean {
  const window = resolveEffectiveKnockoutWindow(roundKey, config);
  if (!window) return false;
  const today = formatVenueCalendarDate(now);
  return today >= window.openDate && today <= window.closeDate;
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

export function formatKnockoutWindowRange(window: KnockoutRoundWindow): string {
  return `${formatCalendarDateYmd(window.openDate)} – ${formatCalendarDateYmd(window.closeDate)}`;
}

export function knockoutPredictionClosedReason(
  match: { stage?: string | null; round_key?: string | null; status: string },
  lockAt: Date,
  now = new Date(),
  config: KnockoutPredictionConfig | null = null
): string | null {
  if (match.status === "FINISHED") {
    return "El partido ya finalizó; no se pueden crear ni modificar predicciones";
  }
  if (match.status === "LIVE") {
    return "El partido está en juego; predicciones cerradas";
  }
  if (match.stage === "KNOCKOUT" && !isKnockoutRoundOpenForPredictions(match.round_key, now, config)) {
    const window = resolveEffectiveKnockoutWindow(match.round_key, config);
    const today = formatVenueCalendarDate(now);
    const adminWindow = hasAdminKnockoutWindow(config);
    const sourceLabel = adminWindow ? "configuración admin" : "calendario sede";

    if (window) {
      if (today < window.openDate) {
        if (adminWindow) {
          return `Las predicciones de eliminatorias se habilitan el ${formatCalendarDateYmd(window.openDate)} (${sourceLabel})`;
        }
        const roundLabel =
          ROUND_SHORT_LABELS[match.round_key?.toUpperCase() ?? ""] ?? "esta ronda eliminatoria";
        return `Las predicciones de ${roundLabel} se abren el ${formatCalendarDateYmd(window.openDate)} (${sourceLabel})`;
      }
      if (adminWindow) {
        return `Las predicciones de eliminatorias cerraron el ${formatCalendarDateYmd(window.closeDate)} (${sourceLabel})`;
      }
      const roundLabel =
        ROUND_SHORT_LABELS[match.round_key?.toUpperCase() ?? ""] ?? "esta ronda eliminatoria";
      return `Las predicciones de ${roundLabel} cerraron el ${formatCalendarDateYmd(window.closeDate)} (${sourceLabel})`;
    }
    return "Las predicciones de eliminatorias no están abiertas en esta fecha";
  }
  if (now.getTime() >= lockAt.getTime()) {
    return `Predicciones cerradas desde ${lockAt.toLocaleString("es-ES")}`;
  }
  return null;
}

export interface PredictionWindowApi {
  openDate: string;
  closeDate: string;
  isOpen: boolean;
  globalOpenDate?: string | null;
  globalCloseDate?: string | null;
  source?: "admin" | "fixture";
}

export function buildKnockoutPredictionWindowApi(
  roundKey: string | null | undefined,
  now = new Date(),
  config: KnockoutPredictionConfig | null = null
): PredictionWindowApi | null {
  const effective = resolveEffectiveKnockoutWindow(roundKey, config);
  if (!effective) return null;
  const adminWindow = hasAdminKnockoutWindow(config);
  return {
    openDate: effective.openDate,
    closeDate: effective.closeDate,
    isOpen: isKnockoutRoundOpenForPredictions(roundKey, now, config),
    globalOpenDate: config?.openDate ?? null,
    globalCloseDate: config?.closeDate ?? null,
    source: adminWindow ? "admin" : "fixture"
  };
}
