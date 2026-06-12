import { pool } from "../../db/pool.js";
import {
  propagateOfficialKnockoutAdvancement,
  syncAllOfficialKnockoutAdvancement
} from "../bracket/knockoutAdvancement.js";
import { matchCalendarDateSql } from "../matches/calendarDate.js";
import { recalculateGroupStandings } from "../standings/recalculate.js";
import { calculateExpertDayBonuses, calculateInvictoAndGroupMasterBonuses } from "./phase1Bonuses.js";
import { calculateQualifierScores, isGroupStageComplete } from "./qualifiers.js";
import { autoFillOfficialR16FromResults } from "../bracket/r16Service.js";
import { syncOfficialBonusResultsAndScore } from "../bracket/deriveBonusFromBracket.js";
import { calculateMatchScores } from "./service.js";

async function syncKnockoutAfterResult(matchId: number): Promise<void> {
  const tourn = await pool.query(
    `SELECT tournament_id FROM matches WHERE id = $1`,
    [matchId]
  );
  const tournamentId = tourn.rows[0]?.tournament_id as number | undefined;
  if (tournamentId) {
    await syncAllOfficialKnockoutAdvancement(tournamentId);
  } else {
    await propagateOfficialKnockoutAdvancement(matchId);
  }
  // Premios del cuadro (semifinalistas, finalistas, campeón…) en cada resultado: los puntos
  // van apareciendo a medida que cada equipo avanza, sin recálculo manual.
  try {
    await syncOfficialBonusResultsAndScore();
  } catch {
    // Bonos parciales o sin datos aún
  }
}

async function scoreGroupStageAfterResult(): Promise<void> {
  // Clasificados a 16avos: se omite en silencio hasta que los 24 estén definidos.
  try {
    await calculateQualifierScores();
  } catch {
    // Faltan grupos por completar
  }

  // Al cerrar la fase de grupos se carga el cuadro oficial de dieciseisavos.
  // Solo llena cruces «Por definir»: las correcciones manuales del admin se respetan.
  try {
    if (await isGroupStageComplete()) {
      await autoFillOfficialR16FromResults({ onlyTbd: true });
    }
  } catch {
    // Cuadro eliminatorio sin importar o terceros aún sin resolver
  }
}

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
    await syncKnockoutAfterResult(matchId);
  }
  if (row?.stage === "GROUP") {
    await scoreGroupStageAfterResult();
  }

  try {
    await calculateExpertDayBonuses();
  } catch {
    // Día aún incompleto o sin predicciones
  }

  try {
    await calculateInvictoAndGroupMasterBonuses();
  } catch {
    // Faltan clasificados oficiales para maestro de grupo
  }
}
