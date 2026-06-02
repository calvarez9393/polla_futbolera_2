import { runSync } from "../modules/sync/service.js";
import { pool } from "../db/pool.js";
runSync("cli")
    .then(async () => {
    console.log("Sync completada");
    await pool.end();
})
    .catch(async (error) => {
    console.error(error);
    await pool.end();
    process.exit(1);
});
