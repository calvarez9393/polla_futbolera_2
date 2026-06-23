import { pool } from "../../db/pool.js";
import {
  buildKnockoutPredictionWindowApi,
  type KnockoutPredictionConfig,
  isKnockoutRoundOpenForPredictions,
  knockoutPredictionClosedReason
} from "../bracket/knockoutPredictionWindow.js";

export { knockoutPredictionClosedReason };

const DATE_YMD = /^\d{4}-\d{2}-\d{2}$/;

function parseOptionalDateYmd(raw: string): string | null {
  const trimmed = raw.trim();
  return DATE_YMD.test(trimmed) ? trimmed : null;
}

export async function loadKnockoutPredictionConfig(): Promise<KnockoutPredictionConfig> {
  return {
    openDate: parseOptionalDateYmd(await getSetting("knockout_predictions_open_date", "")),
    closeDate: parseOptionalDateYmd(await getSetting("knockout_predictions_close_date", ""))
  };
}

export async function getSetting(key: string, fallback = ""): Promise<string> {
  const result = await pool.query("SELECT value FROM app_settings WHERE key = $1", [key]);
  return result.rows[0]?.value ?? fallback;
}

export async function setSetting(key: string, value: string): Promise<void> {
  await pool.query(
    `INSERT INTO app_settings (key, value, updated_at)
    VALUES ($1, $2, NOW())
    ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW()`,
    [key, value]
  );
}

export async function getActiveTournamentId(): Promise<number | null> {
  const season = await getSetting("tournament_season", "2026");
  const bySeason = await pool.query(
    "SELECT id FROM tournaments WHERE season = $1 ORDER BY id DESC LIMIT 1",
    [season]
  );
  if (bySeason.rows[0]) return bySeason.rows[0].id as number;

  const bySlug = await pool.query(
    "SELECT id FROM tournaments WHERE external_id = 'wc-2026' LIMIT 1"
  );
  return (bySlug.rows[0]?.id as number) ?? null;
}

export async function getPredictionLockHours(): Promise<number> {
  const raw = await getSetting("prediction_lock_hours_before", "0");
  const hours = Number(raw);
  return Number.isFinite(hours) && hours >= 0 ? hours : 0;
}

export function computePredictionLockAt(match: {
  starts_at: Date | string;
  prediction_lock_at?: Date | string | null;
}): Date {
  if (match.prediction_lock_at) {
    return new Date(match.prediction_lock_at);
  }
  return new Date(match.starts_at);
}

export async function resolvePredictionLockAt(match: {
  starts_at: Date | string;
  prediction_lock_at?: Date | string | null;
}): Promise<Date> {
  if (match.prediction_lock_at) {
    return new Date(match.prediction_lock_at);
  }
  const hours = await getPredictionLockHours();
  const starts = new Date(match.starts_at);
  return new Date(starts.getTime() - hours * 60 * 60 * 1000);
}

export function isPredictionOpen(lockAt: Date): boolean {
  return Date.now() < lockAt.getTime();
}

/** Predicciones permitidas solo antes del partido, dentro del plazo de cierre y en la ventana de la ronda KO. */
export function isMatchAcceptingPredictions(
  match: { status: string; stage?: string | null; round_key?: string | null },
  lockAt: Date,
  now = new Date(),
  knockoutConfig: KnockoutPredictionConfig | null = null,
  groupStageComplete = false
): boolean {
  if (match.status === "FINISHED" || match.status === "LIVE") {
    return false;
  }
  if (!isPredictionOpen(lockAt)) {
    return false;
  }
  if (
    match.stage === "KNOCKOUT" &&
    !isKnockoutRoundOpenForPredictions(match.round_key, now, knockoutConfig, groupStageComplete)
  ) {
    return false;
  }
  return true;
}

export async function buildPredictionAvailability(
  match: { status: string; stage?: string | null; round_key?: string | null },
  lockAt: Date,
  now = new Date(),
  knockoutConfig?: KnockoutPredictionConfig | null,
  groupStageComplete = false
) {
  const config =
    match.stage === "KNOCKOUT"
      ? (knockoutConfig ?? (await loadKnockoutPredictionConfig()))
      : null;
  const predictionWindow =
    match.stage === "KNOCKOUT"
      ? buildKnockoutPredictionWindowApi(match.round_key, now, config, groupStageComplete)
      : null;
  return {
    predictionsOpen: isMatchAcceptingPredictions(match, lockAt, now, config, groupStageComplete),
    predictionWindow
  };
}
