import { pool } from "../../db/pool.js";
import { propagateOfficialKnockoutAdvancement } from "../bracket/knockoutAdvancement.js";
import { matchCalendarDateSql } from "../matches/calendarDate.js";
import { recalculateGroupStandings } from "../standings/recalculate.js";
import { calculateExpertDayBonuses } from "./phase1Bonuses.js";
import { calculateMatchScores } from "./service.js";
/** Calcula puntos de predicciones y actualiza tabla del grupo si aplica. */
export async function finalizeMatch(matchId) {
    await calculateMatchScores(matchId);
    const match = await pool.query(`SELECT group_id, stage, ${matchCalendarDateSql("matches")} AS match_date FROM matches WHERE id = $1`, [matchId]);
    const row = match.rows[0];
    if (row?.group_id && row.stage === "GROUP") {
        await recalculateGroupStandings(row.group_id);
    }
    if (row?.stage === "KNOCKOUT") {
        await propagateOfficialKnockoutAdvancement(matchId);
    }
    try {
        await calculateExpertDayBonuses();
    }
    catch {
        // Día aún incompleto o sin predicciones
    }
}
