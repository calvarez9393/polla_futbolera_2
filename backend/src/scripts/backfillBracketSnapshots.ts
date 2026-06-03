/**
 * Rellena bracket_home/away en predicciones KO existentes y recalcula puntos.
 * Uso: npx tsx src/scripts/backfillBracketSnapshots.ts
 */
import { pool } from "../db/pool.js";
import { getActiveTournamentId } from "../modules/settings/service.js";
import { resolveUserSlotTeamsForMatch } from "../modules/bracket/resolveUserSlotTeams.js";
import { calculateMatchScores } from "../modules/scoring/service.js";
import { syncOfficialBonusResultsAndScore } from "../modules/bracket/deriveBonusFromBracket.js";

async function main() {
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) {
    console.error("No hay torneo activo");
    process.exit(1);
  }

  const preds = await pool.query(
    `SELECT p.id, p.user_id, p.match_id, m.external_id, m.stage, m.round_key,
      m.home_team_id, m.away_team_id, m.tournament_id
    FROM predictions p
    JOIN matches m ON m.id = p.match_id
    WHERE m.tournament_id = $1 AND m.stage = 'KNOCKOUT'`,
    [tournamentId]
  );

  let updated = 0;
  for (const row of preds.rows) {
    const slot = await resolveUserSlotTeamsForMatch(Number(row.user_id), row);
    if (!slot) continue;
    await pool.query(
      `UPDATE predictions SET bracket_home_team_id = $1, bracket_away_team_id = $2 WHERE id = $3`,
      [slot.homeTeamId, slot.awayTeamId, row.id]
    );
    updated++;
  }
  console.log(`Snapshots actualizados: ${updated}`);

  const finished = await pool.query(
    `SELECT id FROM matches
    WHERE tournament_id = $1 AND stage = 'KNOCKOUT' AND status = 'FINISHED'
      AND home_score IS NOT NULL`,
    [tournamentId]
  );
  for (const row of finished.rows) {
    await calculateMatchScores(Number(row.id));
  }
  console.log(`Partidos recalculados: ${finished.rowCount}`);

  const bonus = await syncOfficialBonusResultsAndScore();
  console.log("Bonos oficiales:", bonus.official);
  console.log(`Usuarios puntuados en bonos: ${bonus.usersScored}`);
  process.exit(0);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
