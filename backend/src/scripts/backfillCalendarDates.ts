import { pool } from "../db/pool.js";
import { WC2026_GROUP_FIXTURES } from "../modules/import/worldCup2026Fixtures.js";
import { WC2026_KNOCKOUT_FIXTURES } from "../modules/import/worldCup2026Knockout.js";

/** Rellena calendar_date y kickoff_time_local desde el calendario importado (idempotente). */
export async function backfillCalendarDates(): Promise<number> {
  let updated = 0;

  for (const f of WC2026_GROUP_FIXTURES) {
    const externalId = `wc2026-match-${String(f.num).padStart(3, "0")}`;
    const result = await pool.query(
      `UPDATE matches SET calendar_date = $1::date, kickoff_time_local = $2
      WHERE external_id = $3`,
      [f.dateLocal, f.timeLocal, externalId]
    );
    updated += result.rowCount ?? 0;
  }

  for (const fx of WC2026_KNOCKOUT_FIXTURES) {
    const result = await pool.query(
      `UPDATE matches SET calendar_date = $1::date, kickoff_time_local = $2
      WHERE external_id = $3`,
      [fx.dateLocal, fx.timeLocal, `wc2026-ko-${fx.num}`]
    );
    updated += result.rowCount ?? 0;
  }

  return updated;
}
