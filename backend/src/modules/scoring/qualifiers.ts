import { pool } from "../../db/pool.js";
import { recalculateGroupStandings } from "../standings/recalculate.js";
import { getActiveTournamentId, getSetting, setSetting } from "../settings/service.js";
import { loadOfficialScoringRules } from "./loadRules.js";

const OFFICIAL_QUALIFIERS_KEY = "official_qualified_team_ids";
export const OFFICIAL_QUALIFIERS_COUNT = 24;

export async function setOfficialQualifiedTeams(teamIds: number[]): Promise<void> {
  await setSetting(OFFICIAL_QUALIFIERS_KEY, JSON.stringify(teamIds));
}

export async function getOfficialQualifiedTeams(): Promise<number[]> {
  const raw = await getSetting(OFFICIAL_QUALIFIERS_KEY, "[]");
  try {
    const parsed = JSON.parse(raw) as number[];
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

/** True solo cuando todos los partidos de fase de grupos del torneo activo están finalizados. */
export async function isGroupStageComplete(): Promise<boolean> {
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) return false;

  const result = await pool.query(
    `SELECT COUNT(*)::int AS total,
      COUNT(*) FILTER (
        WHERE status = 'FINISHED' AND home_score IS NOT NULL AND away_score IS NOT NULL
      )::int AS finished
    FROM matches
    WHERE tournament_id = $1 AND stage = 'GROUP'`,
    [tournamentId]
  );
  const row = result.rows[0];
  return Number(row?.total ?? 0) > 0 && Number(row.finished) === Number(row.total);
}

/** Top 2 por grupo según standings oficiales (resultados finalizados). */
export async function computeOfficialQualifiersFromResults(): Promise<number[]> {
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) return [];

  // Los standings rankean a todos los equipos aunque falten partidos, así que el top 2
  // solo es válido cuando la fase de grupos terminó por completo.
  if (!(await isGroupStageComplete())) return [];

  const groups = await pool.query(
    `SELECT id FROM groups WHERE tournament_id = $1 ORDER BY name`,
    [tournamentId]
  );

  const teamIds: number[] = [];
  for (const g of groups.rows) {
    await recalculateGroupStandings(g.id as number);
    const top2 = await pool.query(
      `SELECT team_id FROM standings WHERE group_id = $1 AND rank <= 2 ORDER BY rank`,
      [g.id]
    );
    for (const row of top2.rows) {
      teamIds.push(row.team_id as number);
    }
  }

  return teamIds;
}

/**
 * Garantiza la lista de 24 clasificados (top 2 × 12 grupos) para puntaje de clasificados y bono maestro.
 * No confundir con los 32 equipos del cuadro de dieciseisavos.
 */
export async function ensureOfficialQualifiedTeams(): Promise<number[]> {
  if (!(await isGroupStageComplete())) {
    throw new Error(
      "La fase de grupos no ha terminado: los puntos de clasificados y el bono maestro de grupo " +
        "solo se calculan cuando finaliza el último partido de grupos."
    );
  }

  const saved = await getOfficialQualifiedTeams();
  if (saved.length === OFFICIAL_QUALIFIERS_COUNT) return saved;

  const fromStandings = await computeOfficialQualifiersFromResults();
  if (fromStandings.length === OFFICIAL_QUALIFIERS_COUNT) {
    await setOfficialQualifiedTeams(fromStandings);
    return fromStandings;
  }

  throw new Error(
    `Se necesitan ${OFFICIAL_QUALIFIERS_COUNT} clasificados oficiales (top 2 por grupo). ` +
      `Guardados: ${saved.length}. Detectados desde tablas: ${fromStandings.length}. ` +
      `Guarda los 24 en esta página o finaliza todos los partidos de grupos. ` +
      `(El cuadro de 32 en dieciseisavos es independiente.)`
  );
}

export async function calculateQualifierScores(): Promise<{ usersScored: number }> {
  const official = await ensureOfficialQualifiedTeams();

  const rules = await loadOfficialScoringRules();
  const officialSet = new Set(official);
  const preds = await pool.query("SELECT user_id, team_id FROM qualifier_predictions");
  const byUser = new Map<number, number[]>();

  for (const row of preds.rows) {
    const uid = row.user_id as number;
    const tid = row.team_id as number;
    if (!byUser.has(uid)) byUser.set(uid, []);
    byUser.get(uid)!.push(tid);
  }

  let usersScored = 0;
  for (const [userId, picks] of byUser) {
    const correct = picks.filter((id) => officialSet.has(id)).length;
    const points = correct * rules.qualified_team_points;
    const breakdown = { qualifiedTeams: points, correctCount: correct };

    await pool.query(
      `INSERT INTO prediction_scores (user_id, source_type, source_id, points, breakdown)
      VALUES ($1, 'QUALIFIERS', 0, $2, $3::jsonb)
      ON CONFLICT (user_id, source_type, source_id)
      DO UPDATE SET points = EXCLUDED.points, breakdown = EXCLUDED.breakdown, updated_at = NOW()`,
      [userId, points, JSON.stringify(breakdown)]
    );
    usersScored += 1;
  }

  return { usersScored };
}
