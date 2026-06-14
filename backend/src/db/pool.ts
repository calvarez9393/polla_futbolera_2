import { Pool, types } from "pg";
import { env } from "../config/env.js";

// Las columnas DATE (p. ej. matches.calendar_date) deben volver como texto 'YYYY-MM-DD'.
// Por defecto node-pg las convierte a un Date a medianoche LOCAL del servidor, lo que en
// servidores con huso UTC+X corre la fecha un día (el día UTC del Date no coincide con el día real).
// Devolverlas crudas hace que las fechas de calendario sean independientes del huso del servidor.
types.setTypeParser(types.builtins.DATE, (value) => value);

export const pool = new Pool({
  connectionString: env.DATABASE_URL
});
