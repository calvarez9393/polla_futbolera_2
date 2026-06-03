import { pool } from "../../db/pool.js";
import { setOfficialBonusResults } from "../scoring/bonuses.js";
import { setOfficialQualifiedTeams } from "../scoring/qualifiers.js";
import { recalculateGroupStandings } from "../standings/recalculate.js";
import { getActiveTournamentId } from "../settings/service.js";

export interface ResetCompetitionResult {
  predictionScores: number;
  predictions: number;
  qualifierPredictions: number;
  groupPredictions: number;
  bonusPredictions: number;
  matchesReset: number;
  knockoutTeamsReset: number;
}

/**
 * Reinicia estado competitivo del torneo activo:
 * puntos, predicciones, bonos, marcadores y cruces KO (TBD).
 * No borra usuarios ni el calendario importado.
 */
export async function resetCompetitionData(
  tournamentId?: number
): Promise<ResetCompetitionResult> {
  const tid = tournamentId ?? (await getActiveTournamentId());
  if (!tid) {
    throw new Error("No hay torneo activo");
  }

  const scores = await pool.query(`DELETE FROM prediction_scores`);
  const preds = await pool.query(
    `DELETE FROM predictions p
     USING matches m
     WHERE p.match_id = m.id AND m.tournament_id = $1`,
    [tid]
  );
  const qualifiers = await pool.query(`DELETE FROM qualifier_predictions`);
  const groupPreds = await pool.query(
    `DELETE FROM group_predictions gp
     USING groups g
     WHERE gp.group_id = g.id AND g.tournament_id = $1`,
    [tid]
  );
  const bonuses = await pool.query(`DELETE FROM bonus_predictions`);

  const matches = await pool.query(
    `UPDATE matches SET
      status = 'NOT_STARTED',
      home_score = NULL,
      away_score = NULL,
      winner_team_id = NULL,
      updated_at = NOW()
    WHERE tournament_id = $1`,
    [tid]
  );

  const tbd = await pool.query("SELECT id FROM teams WHERE external_id = 'wc2026-tbd' LIMIT 1");
  let knockoutTeamsReset = 0;
  if (tbd.rows[0]) {
    const knockoutTeams = await pool.query(
      `UPDATE matches SET
        home_team_id = $2,
        away_team_id = $2,
        updated_at = NOW()
      WHERE tournament_id = $1 AND stage = 'KNOCKOUT'`,
      [tid, tbd.rows[0].id]
    );
    knockoutTeamsReset = knockoutTeams.rowCount ?? 0;
  }

  await setOfficialQualifiedTeams([]);
  await setOfficialBonusResults({});

  const groupIds = await pool.query(`SELECT id FROM groups WHERE tournament_id = $1`, [tid]);
  for (const row of groupIds.rows) {
    await recalculateGroupStandings(row.id as number);
  }

  return {
    predictionScores: scores.rowCount ?? 0,
    predictions: preds.rowCount ?? 0,
    qualifierPredictions: qualifiers.rowCount ?? 0,
    groupPredictions: groupPreds.rowCount ?? 0,
    bonusPredictions: bonuses.rowCount ?? 0,
    matchesReset: matches.rowCount ?? 0,
    knockoutTeamsReset
  };
}
