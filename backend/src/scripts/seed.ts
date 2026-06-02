import bcrypt from "bcrypt";
import { env } from "../config/env.js";
import { pool } from "../db/pool.js";

async function run(): Promise<void> {
  const login = env.ADMIN_LOGIN;
  const passwordHash = await bcrypt.hash(env.ADMIN_PASSWORD, 10);
  const result = await pool.query(
    `INSERT INTO users (email, password_hash, role)
    VALUES ($1, $2, 'ADMIN')
    ON CONFLICT (email) DO NOTHING
    RETURNING id`,
    [login, passwordHash]
  );
  if (result.rows[0]) {
    console.log(`Admin creado: ${login}`);
  } else {
    console.log(`Admin ya existía: ${login} (contraseña no modificada)`);
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
