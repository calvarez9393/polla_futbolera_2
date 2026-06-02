import bcrypt from "bcrypt";
import { env } from "../config/env.js";
import { pool } from "../db/pool.js";
async function run() {
    const email = env.ADMIN_EMAIL.toLowerCase();
    const passwordHash = await bcrypt.hash(env.ADMIN_PASSWORD, 10);
    const result = await pool.query(`INSERT INTO users (email, password_hash, role)
    VALUES ($1, $2, 'ADMIN')
    ON CONFLICT (email) DO NOTHING
    RETURNING id`, [email, passwordHash]);
    if (result.rows[0]) {
        console.log(`Admin creado: ${email}`);
    }
    else {
        console.log(`Admin ya existía: ${email} (contraseña no modificada)`);
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
