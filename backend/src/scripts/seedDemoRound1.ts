/**
 * Carga de prueba: usuarios demo + predicciones fase de grupos (todas las jornadas por defecto).
 *
 * Uso:
 *   npm run seed:demo-round1
 *   npm run seed:demo-round1 -- --clean   (borra puntos, resultados y todas las predicciones)
 *   npm run seed:demo-round1 -- --matchday 2        (solo una jornada)
 *   npm run seed:demo-round1 -- --finalize          (opcional: resultados + puntos)
 *
 * Login: demo001@polla.local … / contraseña: pollademo
 */
import bcrypt from "bcrypt";
import { pool } from "../db/pool.js";
import { getActiveTournamentId } from "../modules/settings/service.js";
import { setOfficialQualifiedTeams } from "../modules/scoring/qualifiers.js";
import { setOfficialBonusResults } from "../modules/scoring/bonuses.js";
import { finalizeMatch } from "../modules/scoring/finalize.js";
import { syncAllUsersQualifierPredictions } from "../modules/qualifiers/fromPredictions.js";
import { env } from "../config/env.js";

const DEMO_DOMAIN = "polla.local";
const DEFAULT_PASSWORD = process.env.SEED_DEMO_PASSWORD ?? "pollademo";
const DEFAULT_USERS = 100;

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
    WHERE email ~ '^demo[0-9]+@${DEMO_DOMAIN.replace(".", "\\.")}$'
    RETURNING id`
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
    const num = String(n).padStart(3, "0");
    const email = `demo${num}@${DEMO_DOMAIN}`;
    const displayName = `Demo ${num}`;
    const result = await pool.query(
      `INSERT INTO users (email, password_hash, role, display_name, amount_paid)
      VALUES ($1, $2, 'USER', $3, 50000)
      ON CONFLICT (email) DO UPDATE SET
        display_name = EXCLUDED.display_name,
        role = 'USER'
      RETURNING id`,
      [email, passwordHash, displayName]
    );
    ids.push(result.rows[0].id as number);
  }
  return ids;
}

async function getAdminUserIds(): Promise<Array<{ id: number; email: string }>> {
  const result = await pool.query(
    `SELECT id, email FROM users WHERE role = 'ADMIN' ORDER BY email`
  );
  return result.rows.map((r) => ({
    id: r.id as number,
    email: r.email as string
  }));
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
  const admins = await getAdminUserIds();
  if (admins.length === 0) {
    console.warn(`⚠️  No hay usuario ADMIN en BD. Crea uno con: npm run seed (${env.ADMIN_LOGIN})`);
  }
  const userIds = [...new Set([...demoIds, ...admins.map((a) => a.id)])];

  console.log(`Usuarios demo: ${demoIds.length} (demo001@${DEMO_DOMAIN} …)`);
  if (admins.length > 0) {
    console.log(`Admin(s) con predicciones: ${admins.map((a) => a.email).join(", ")}`);
  }

  const predCount = await seedPredictions(userIds, matches);
  console.log(`Predicciones: ${predCount} (${userIds.length} participantes × ${matches.length} partidos)`);

  const sync = await syncAllUsersQualifierPredictions();
  console.log(`Clasificados simulados: ${sync.users} participantes (incluye admin)`);

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
    [userIds, matchIds]
  );
  const s = predStats.rows[0];
  console.log(`\nResumen: ${s.users} usuarios · ${s.predictions} predicciones · ${scopeLabel}`);
  console.log(`Contraseña: ${password} · Ejemplo: demo001@${DEMO_DOMAIN}\n`);
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
