import { pool } from "../db/pool.js";
import { flagUrlForTeam, TEAM_FLAG_CODES } from "../modules/import/teamFlags.js";

async function main() {
  let updated = 0;
  for (const name of Object.keys(TEAM_FLAG_CODES)) {
    const logoUrl = flagUrlForTeam(name);
    const result = await pool.query(
      `UPDATE teams SET logo_url = $1 WHERE name = $2 AND (logo_url IS NULL OR logo_url <> $1)`,
      [logoUrl, name]
    );
    updated += result.rowCount ?? 0;
  }
  console.log(`Banderas actualizadas en ${updated} equipos`);
  await pool.end();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
