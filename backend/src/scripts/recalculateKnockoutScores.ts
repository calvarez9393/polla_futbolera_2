/**
 * Recalcula puntos de todos los partidos eliminatorios finalizados
 * (p. ej. tras corregir la lógica cuadro usuario vs resultado real).
 *
 * Uso: npx tsx src/scripts/recalculateKnockoutScores.ts
 */
import { pool } from "../db/pool.js";
import { getActiveTournamentId } from "../modules/settings/service.js";
import { calculateMatchScores } from "../modules/scoring/service.js";

async function main() {
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) {
    console.error("No hay torneo activo");
    process.exit(1);
  }

  const result = await pool.query(
    `SELECT id, external_id FROM matches
    WHERE tournament_id = $1 AND stage = 'KNOCKOUT' AND status = 'FINISHED'
      AND home_score IS NOT NULL AND away_score IS NOT NULL
    ORDER BY starts_at ASC`,
    [tournamentId]
  );

  let ok = 0;
  for (const row of result.rows) {
    await calculateMatchScores(Number(row.id));
    ok++;
    console.log(`OK match ${row.external_id} (id=${row.id})`);
  }

  console.log(`Recalculados ${ok} partidos eliminatorios.`);
  process.exit(0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
