import { pool } from "../../db/pool.js";
import { WC2026_KNOCKOUT_FIXTURES } from "../bracket/wc2026KnockoutFixtures.js";
export { WC2026_KNOCKOUT_FIXTURES } from "../bracket/wc2026KnockoutFixtures.js";
async function ensureTbdTeam(tournamentId) {
    const existing = await pool.query("SELECT id FROM teams WHERE external_id = 'wc2026-tbd' LIMIT 1");
    if (existing.rows[0])
        return existing.rows[0].id;
    const inserted = await pool.query(`INSERT INTO teams (external_id, name, short_name, logo_url)
    VALUES ('wc2026-tbd', 'Por definir', 'TBD', NULL)
    RETURNING id`);
    return inserted.rows[0].id;
}
function kickoffUtc(dateLocal, timeLocal) {
    return new Date(`${dateLocal}T${timeLocal}:00-05:00`);
}
export async function importWorldCup2026Knockout() {
    const tournament = await pool.query("SELECT id FROM tournaments WHERE external_id = 'wc-2026'");
    if (!tournament.rows[0]) {
        throw new Error("Importa primero el calendario de grupos (Mundial 2026)");
    }
    const tournamentId = tournament.rows[0].id;
    const tbdId = await ensureTbdTeam(tournamentId);
    await pool.query(`DELETE FROM prediction_scores WHERE source_type = 'MATCH' AND source_id IN (
      SELECT id FROM matches WHERE tournament_id = $1 AND stage = 'KNOCKOUT'
    )`, [tournamentId]);
    await pool.query("DELETE FROM predictions WHERE match_id IN (SELECT id FROM matches WHERE tournament_id = $1 AND stage = 'KNOCKOUT')", [tournamentId]);
    await pool.query("DELETE FROM matches WHERE tournament_id = $1 AND stage = 'KNOCKOUT'", [tournamentId]);
    let count = 0;
    for (const fx of WC2026_KNOCKOUT_FIXTURES) {
        const startsAt = kickoffUtc(fx.dateLocal, fx.timeLocal);
        const lockAt = new Date(startsAt.getTime() - 24 * 60 * 60 * 1000);
        const label = `${fx.roundLabel} · ${fx.homeSlot} vs ${fx.awaySlot}`;
        await pool.query(`INSERT INTO matches (
        external_id, tournament_id, group_id, stage, round_key, status, starts_at, calendar_date,
        kickoff_time_local, round_label, matchday, prediction_lock_at, home_team_id, away_team_id
      ) VALUES ($1,$2,NULL,'KNOCKOUT',$3,'NOT_STARTED',$4,$5,$6,$7,NULL,$8,$9,$9)`, [
            `wc2026-ko-${fx.num}`,
            tournamentId,
            fx.roundKey,
            startsAt.toISOString(),
            fx.dateLocal,
            fx.timeLocal,
            label,
            lockAt.toISOString(),
            tbdId
        ]);
        count += 1;
    }
    return { matches: count };
}
