/**
 * Carga de prueba: usuarios demo + predicciones fase de grupos (todas las jornadas por defecto).
 *
 * Uso:
 *   npm run seed:demo-round1
 *   npm run seed:demo-round1 -- --clean   (borra puntos, resultados y todas las predicciones)
 *   npm run seed:demo-round1 -- --users 5           (por defecto: 5)
 *   npm run seed:demo-round1 -- --matchday 2        (solo una jornada)
 *   npm run seed:demo-round1 -- --finalize          (opcional: resultados + puntos)
 *
 * Login numérico: 900001 … 900005 / contraseña: pollademo
 */
import bcrypt from "bcrypt";
import { pool } from "../db/pool.js";
import { getActiveTournamentId } from "../modules/settings/service.js";
import { setOfficialQualifiedTeams } from "../modules/scoring/qualifiers.js";
import { setOfficialBonusResults } from "../modules/scoring/bonuses.js";
import { finalizeMatch } from "../modules/scoring/finalize.js";
import { syncUserQualifierPredictions } from "../modules/qualifiers/fromPredictions.js";

/** Códigos demo: 900001, 900002, … */
const DEMO_LOGIN_BASE = 900_000;
const DEMO_LOGIN_PATTERN = "^900[0-9]{3}$";
const LEGACY_DEMO_EMAIL_PATTERN = "^demo[0-9]+@polla\\.local$";
const DEFAULT_PASSWORD = process.env.SEED_DEMO_PASSWORD ?? "pollademo";
const DEFAULT_USERS = 5;

function demoLogin(n: number): string {
  return String(DEMO_LOGIN_BASE + n);
}

interface MatchRow {
  id: number;
  matchday: number | null;
  home_team_id: number;
  away_team_id: number;
  group_id: number;
}

function parseArgs() {
  const argv = process.argv.slice(2);
  let users = DEFAULT_USERS;
  let matchday: number | null = null;
  let clean = false;
  let finalize = false;
  let password = DEFAULT_PASSWORD;

  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--clean") clean = true;
    else if (a === "--finalize") finalize = true;
    else if (a === "--users" && argv[i + 1]) users = Number(argv[++i]);
    else if (a === "--matchday" && argv[i + 1]) matchday = Number(argv[++i]);
    else if (a === "--password" && argv[i + 1]) password = argv[++i];
  }

  return { users, matchday, clean, finalize, password };
}

function randomGoals(): number {
  const r = Math.random();
  if (r < 0.32) return 0;
  if (r < 0.62) return 1;
  if (r < 0.84) return 2;
  if (r < 0.95) return 3;
  return 4;
}

function randomScorePair(): { home: number; away: number } {
  let home = randomGoals();
  let away = randomGoals();
  if (home === 0 && away === 0 && Math.random() < 0.55) {
    if (Math.random() < 0.5) home = 1;
    else away = 1;
  }
  return { home, away };
}

async function cleanDemoUsers(): Promise<number> {
  const result = await pool.query(
    `DELETE FROM users
    WHERE email ~ $1 OR email ~ $2
    RETURNING id`,
    [DEMO_LOGIN_PATTERN, LEGACY_DEMO_EMAIL_PATTERN]
  );
  return result.rowCount ?? 0;
}

/** Elimina códigos demo sobrantes (p. ej. 900006+) de cargas anteriores. */
async function purgeExtraDemoUsers(keepCount: number): Promise<number> {
  const allowed = Array.from({ length: keepCount }, (_, i) => demoLogin(i + 1));
  const result = await pool.query(
    `DELETE FROM users
    WHERE email ~ $1
      AND NOT (email = ANY($2::text[]))
    RETURNING id`,
    [DEMO_LOGIN_PATTERN, allowed]
  );
  return result.rowCount ?? 0;
}

/** Limpia estado competitivo del torneo: puntos, predicciones y marcadores oficiales. */
async function cleanCompetitionData(tournamentId: number): Promise<{
  predictionScores: number;
  predictions: number;
  qualifierPredictions: number;
  groupPredictions: number;
  bonusPredictions: number;
  matchesReset: number;
  knockoutTeamsReset: number;
}> {
  const scores = await pool.query(`DELETE FROM prediction_scores`);
  const preds = await pool.query(
    `DELETE FROM predictions p
     USING matches m
     WHERE p.match_id = m.id AND m.tournament_id = $1`,
    [tournamentId]
  );
  const qualifiers = await pool.query(`DELETE FROM qualifier_predictions`);
  const groupPreds = await pool.query(
    `DELETE FROM group_predictions gp
     USING groups g
     WHERE gp.group_id = g.id AND g.tournament_id = $1`,
    [tournamentId]
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
    [tournamentId]
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
      [tournamentId, tbd.rows[0].id]
    );
    knockoutTeamsReset = knockoutTeams.rowCount ?? 0;
  }

  await setOfficialQualifiedTeams([]);
  await setOfficialBonusResults({});

  const groupIds = await pool.query(`SELECT id FROM groups WHERE tournament_id = $1`, [tournamentId]);
  const { recalculateGroupStandings } = await import("../modules/standings/recalculate.js");
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

async function ensureUsers(count: number, passwordHash: string): Promise<number[]> {
  const ids: number[] = [];
  for (let n = 1; n <= count; n++) {
    const login = demoLogin(n);
    const displayName = `Demo ${n}`;
    const result = await pool.query(
      `INSERT INTO users (email, password_hash, role, display_name, amount_paid)
      VALUES ($1, $2, 'USER', $3, 50000)
      ON CONFLICT (email) DO UPDATE SET
        display_name = EXCLUDED.display_name,
        role = 'USER'
      RETURNING id`,
      [login, passwordHash, displayName]
    );
    ids.push(result.rows[0].id as number);
  }
  return ids;
}

async function getGroupMatches(matchday: number | null): Promise<MatchRow[]> {
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) {
    throw new Error("No hay torneo activo. Importa el calendario WC2026 desde Admin.");
  }

  const result = matchday
    ? await pool.query(
        `SELECT id, matchday, home_team_id, away_team_id, group_id
        FROM matches
        WHERE tournament_id = $1 AND stage = 'GROUP' AND matchday = $2
        ORDER BY matchday ASC, starts_at ASC`,
        [tournamentId, matchday]
      )
    : await pool.query(
        `SELECT id, matchday, home_team_id, away_team_id, group_id
        FROM matches
        WHERE tournament_id = $1 AND stage = 'GROUP'
        ORDER BY matchday ASC NULLS LAST, starts_at ASC`,
        [tournamentId]
      );

  return result.rows.map((r) => ({
    id: r.id as number,
    matchday: r.matchday as number | null,
    home_team_id: r.home_team_id as number,
    away_team_id: r.away_team_id as number,
    group_id: r.group_id as number
  }));
}

/** Deja partidos de grupos sin resultado para que el admin cargue oficiales. */
async function resetGroupMatchesResults(matchIds: number[]): Promise<void> {
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId || matchIds.length === 0) return;

  await pool.query(
    `DELETE FROM prediction_scores ps
    WHERE ps.source_type = 'MATCH' AND ps.source_id = ANY($1::bigint[])`,
    [matchIds]
  );

  await pool.query(
    `UPDATE matches SET
      status = 'NOT_STARTED',
      home_score = NULL,
      away_score = NULL,
      winner_team_id = NULL,
      updated_at = NOW()
    WHERE id = ANY($1::bigint[])`,
    [matchIds]
  );

  const groupIds = await pool.query(
    `SELECT DISTINCT group_id FROM matches
    WHERE id = ANY($1::bigint[]) AND group_id IS NOT NULL`,
    [matchIds]
  );
  const { recalculateGroupStandings } = await import("../modules/standings/recalculate.js");
  for (const row of groupIds.rows) {
    await recalculateGroupStandings(row.group_id as number);
  }
}

async function seedPredictions(userIds: number[], matches: MatchRow[]): Promise<number> {
  const BATCH = 200;
  let inserted = 0;
  const values: Array<[number, number, number, number]> = [];

  for (const userId of userIds) {
    for (const m of matches) {
      const { home, away } = randomScorePair();
      values.push([userId, m.id, home, away]);
    }
  }

  for (let i = 0; i < values.length; i += BATCH) {
    const chunk = values.slice(i, i + BATCH);
    const params: unknown[] = [];
    const placeholders: string[] = [];
    let p = 1;
    for (const [userId, matchId, home, away] of chunk) {
      placeholders.push(`($${p}, $${p + 1}, $${p + 2}, $${p + 3})`);
      params.push(userId, matchId, home, away);
      p += 4;
    }
    await pool.query(
      `INSERT INTO predictions (user_id, match_id, predicted_home_score, predicted_away_score)
      VALUES ${placeholders.join(", ")}
      ON CONFLICT (user_id, match_id)
      DO UPDATE SET
        predicted_home_score = EXCLUDED.predicted_home_score,
        predicted_away_score = EXCLUDED.predicted_away_score,
        updated_at = NOW()`,
      params
    );
    inserted += chunk.length;
  }

  return inserted;
}

async function finalizeMatches(matches: MatchRow[]): Promise<void> {
  const groupIds = new Set<number>();

  for (const m of matches) {
    const { home, away } = randomScorePair();
    const winnerId =
      home > away ? m.home_team_id : away > home ? m.away_team_id : null;

    await pool.query(
      `UPDATE matches SET
        status = 'FINISHED',
        home_score = $1,
        away_score = $2,
        winner_team_id = $3,
        updated_at = NOW()
      WHERE id = $4`,
      [home, away, winnerId, m.id]
    );

    await finalizeMatch(m.id);
    if (m.group_id) groupIds.add(m.group_id);
  }

  console.log(`  Partidos finalizados: ${matches.length} (grupos: ${groupIds.size})`);
}

function summarizeByMatchday(matches: MatchRow[]): Map<number, number> {
  const map = new Map<number, number>();
  for (const m of matches) {
    const j = m.matchday ?? 0;
    map.set(j, (map.get(j) ?? 0) + 1);
  }
  return map;
}

async function run(): Promise<void> {
  const { users, matchday, clean, finalize, password } = parseArgs();
  const scopeLabel = matchday ? `J${matchday}` : "J1 + J2 + J3 (toda la fase de grupos)";

  console.log(`\n🏟️  Seed demo — solo predicciones · ${scopeLabel} · ${users} usuarios\n`);

  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) {
    throw new Error("No hay torneo activo. Importa el calendario WC2026 desde Admin.");
  }

  if (clean) {
    const wiped = await cleanCompetitionData(tournamentId);
    console.log("Limpieza (--clean):");
    console.log(`  Puntos (prediction_scores): ${wiped.predictionScores}`);
    console.log(`  Predicciones de partidos: ${wiped.predictions}`);
    console.log(`  Clasificados (qualifier_predictions): ${wiped.qualifierPredictions}`);
    console.log(`  Orden de grupo (group_predictions): ${wiped.groupPredictions}`);
    console.log(`  Bonos (bonus_predictions): ${wiped.bonusPredictions}`);
    console.log(`  Partidos sin resultado: ${wiped.matchesReset}`);
    console.log(`  Cruces KO devueltos a Por definir: ${wiped.knockoutTeamsReset}`);
    const removed = await cleanDemoUsers();
    console.log(`  Usuarios demo eliminados: ${removed}`);
  }

  const matches = await getGroupMatches(matchday);
  if (matches.length === 0) {
    throw new Error(
      matchday
        ? `No hay partidos con matchday=${matchday}. Importa WC2026 desde Admin.`
        : "No hay partidos de grupos. Importa WC2026 desde Admin."
    );
  }

  const matchIds = matches.map((m) => m.id);
  const byJornada = summarizeByMatchday(matches);
  console.log("Partidos por jornada:");
  for (const [j, count] of [...byJornada.entries()].sort((a, b) => a[0] - b[0])) {
    console.log(`  J${j}: ${count}`);
  }
  console.log(`  Total: ${matches.length}`);

  if (!finalize) {
    await resetGroupMatchesResults(matchIds);
    console.log("Partidos reiniciados (sin marcador oficial)");
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const demoIds = await ensureUsers(users, passwordHash);
  const purged = await purgeExtraDemoUsers(users);
  if (purged > 0) {
    console.log(`Usuarios demo sobrantes eliminados: ${purged}`);
  }

  console.log(`Usuarios demo: ${demoIds.length} (${demoLogin(1)} … ${demoLogin(users)})`);

  const predCount = await seedPredictions(demoIds, matches);
  console.log(`Predicciones: ${predCount} (${demoIds.length} usuarios × ${matches.length} partidos)`);

  for (const userId of demoIds) {
    await syncUserQualifierPredictions(userId);
  }
  console.log(`Clasificados simulados: ${demoIds.length} usuarios demo`);

  if (finalize) {
    console.log("\nModo --finalize: registrando resultados aleatorios y puntos…");
    await finalizeMatches(matches);
  } else {
    console.log("\nCarga los resultados en Admin → Calendario y resultados (jornada a jornada).");
  }

  const predStats = await pool.query(
    `SELECT COUNT(DISTINCT user_id)::int AS users, COUNT(*)::int AS predictions
    FROM predictions
    WHERE user_id = ANY($1::bigint[]) AND match_id = ANY($2::bigint[])`,
    [demoIds, matchIds]
  );
  const s = predStats.rows[0];
  console.log(`\nResumen: ${s.users} usuarios · ${s.predictions} predicciones · ${scopeLabel}`);
  console.log(`Contraseña: ${password} · Ejemplo login: ${demoLogin(1)}\n`);
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
