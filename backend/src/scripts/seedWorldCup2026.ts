import { importWorldCup2026Schedule } from "../modules/import/worldCup2026.js";
import { pool } from "../db/pool.js";

importWorldCup2026Schedule()
  .then(async (result) => {
    console.log("Calendario Mundial 2026 importado:", result);
    await pool.end();
  })
  .catch(async (error) => {
    console.error(error);
    await pool.end();
    process.exit(1);
  });
