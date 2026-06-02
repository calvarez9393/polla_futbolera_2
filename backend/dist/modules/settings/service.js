import { pool } from "../../db/pool.js";
export async function getSetting(key, fallback = "") {
    const result = await pool.query("SELECT value FROM app_settings WHERE key = $1", [key]);
    return result.rows[0]?.value ?? fallback;
}
export async function setSetting(key, value) {
    await pool.query(`INSERT INTO app_settings (key, value, updated_at)
    VALUES ($1, $2, NOW())
    ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW()`, [key, value]);
}
export async function getActiveTournamentId() {
    const season = await getSetting("tournament_season", "2026");
    const bySeason = await pool.query("SELECT id FROM tournaments WHERE season = $1 ORDER BY id DESC LIMIT 1", [season]);
    if (bySeason.rows[0])
        return bySeason.rows[0].id;
    const bySlug = await pool.query("SELECT id FROM tournaments WHERE external_id = 'wc-2026' LIMIT 1");
    return bySlug.rows[0]?.id ?? null;
}
export async function getPredictionLockHours() {
    const raw = await getSetting("prediction_lock_hours_before", "0");
    const hours = Number(raw);
    return Number.isFinite(hours) && hours >= 0 ? hours : 0;
}
export function computePredictionLockAt(match) {
    if (match.prediction_lock_at) {
        return new Date(match.prediction_lock_at);
    }
    return new Date(match.starts_at);
}
export async function resolvePredictionLockAt(match) {
    if (match.prediction_lock_at) {
        return new Date(match.prediction_lock_at);
    }
    const hours = await getPredictionLockHours();
    const starts = new Date(match.starts_at);
    return new Date(starts.getTime() - hours * 60 * 60 * 1000);
}
export function isPredictionOpen(lockAt) {
    return Date.now() < lockAt.getTime();
}
/** Predicciones permitidas solo antes del partido y dentro del plazo de cierre. */
export function isMatchAcceptingPredictions(match, lockAt) {
    if (match.status === "FINISHED" || match.status === "LIVE") {
        return false;
    }
    return isPredictionOpen(lockAt);
}
