import { pool } from "../../db/pool.js";
import {
  propagateOfficialKnockoutAdvancement,
  syncAllOfficialKnockoutAdvancement
} from "../bracket/knockoutAdvancement.js";
import { matchCalendarDateSql } from "../matches/calendarDate.js";
import { recalculateGroupStandings } from "../standings/recalculate.js";
import { calculateExpertDayBonuses } from "./phase1Bonuses.js";
import { syncOfficialBonusResultsAndScore } from "../bracket/deriveBonusFromBracket.js";
import { calculateMatchScores } from "./service.js";

/** Calcula puntos de predicciones y actualiza tabla del grupo si aplica. */
export async function finalizeMatch(matchId: number): Promise<void> {
  await calculateMatchScores(matchId);

  const match = await pool.query(
    `SELECT group_id, stage, ${matchCalendarDateSql("matches")} AS match_date FROM matches WHERE id = $1`,
    [matchId]
  );
  const row = match.rows[0];
  if (row?.group_id && row.stage === "GROUP") {
    await recalculateGroupStandings(row.group_id as number);
  }
  if (row?.stage === "KNOCKOUT") {
    const tourn = await pool.query(
      `SELECT tournament_id, round_key FROM matches WHERE id = $1`,
      [matchId]
    );
    const tournamentId = tourn.rows[0]?.tournament_id as number | undefined;
    const roundKey = tourn.rows[0]?.round_key as string | undefined;
    if (tournamentId) {
      await syncAllOfficialKnockoutAdvancement(tournamentId);
    } else {
      await propagateOfficialKnockoutAdvancement(matchId);
    }
    if (roundKey === "F" || roundKey === "TP3" || roundKey === "SF") {
      try {
        await syncOfficialBonusResultsAndScore();
      } catch {
        // Bonos parciales o sin datos aún
      }
    }
  }

  try {
    await calculateExpertDayBonuses();
  } catch {
    // Día aún incompleto o sin predicciones
  }
}
