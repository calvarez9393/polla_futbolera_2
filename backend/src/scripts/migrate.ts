import { readdir, readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { pool } from "../db/pool.js";
import { backfillCalendarDates } from "./backfillCalendarDates.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function run(): Promise<void> {
  await pool.query(
    "CREATE TABLE IF NOT EXISTS schema_migrations (version TEXT PRIMARY KEY, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW())"
  );

  const migrationsDir = path.join(__dirname, "..", "db", "migrations");
  const files = (await readdir(migrationsDir)).filter((f) => f.endsWith(".sql")).sort();

  for (const file of files) {
    const exists = await pool.query("SELECT 1 FROM schema_migrations WHERE version = $1", [file]);
    if (exists.rows[0]) continue;
    const sql = await readFile(path.join(migrationsDir, file), "utf8");
    await pool.query("BEGIN");
    try {
      await pool.query(sql);
      await pool.query("INSERT INTO schema_migrations (version) VALUES ($1)", [file]);
      await pool.query("COMMIT");
      console.log(`Applied migration ${file}`);
    } catch (error) {
      await pool.query("ROLLBACK");
      throw error;
    }
  }

  const backfilled = await backfillCalendarDates();
  if (backfilled > 0) {
    console.log(`Calendar dates backfilled for ${backfilled} matches`);
  }
}

run()
  .then(async () => {
    await pool.end();
  })
  .catch(async (error) => {
    console.error(error);
    await pool.end();
    process.exit(1);
  });
