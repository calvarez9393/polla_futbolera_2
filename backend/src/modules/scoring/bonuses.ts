import { pool } from "../../db/pool.js";
import { getSetting, setSetting } from "../settings/service.js";
import { loadOfficialScoringRules } from "./loadRules.js";

export interface OfficialBonusResults {
  championTeamId?: number | null;
  runnerUpTeamId?: number | null;
  thirdPlaceTeamId?: number | null;
  semifinalistTeamIds?: number[];
  finalistTeamIds?: number[];
  /** equipo → matches.id del partido que lo consagró (para asignar el premio a ese partido). */
  semifinalistSourceMatchIds?: Record<string, number>;
  finalistSourceMatchIds?: Record<string, number>;
  /** Partido de la final (consagra campeón y subcampeón) y del tercer puesto. */
  championMatchId?: number | null;
  thirdPlaceMatchId?: number | null;
  topScorer?: string | null;
  topAssister?: string | null;
}

const OFFICIAL_BONUSES_KEY = "official_bonus_results";

export async function setOfficialBonusResults(results: OfficialBonusResults): Promise<void> {
  await setSetting(OFFICIAL_BONUSES_KEY, JSON.stringify(results));
}

export async function getOfficialBonusResults(): Promise<OfficialBonusResults> {
  const raw = await getSetting(OFFICIAL_BONUSES_KEY, "{}");
  try {
    return JSON.parse(raw) as OfficialBonusResults;
  } catch {
    return {};
  }
}

function capPoints(raw: number, max: number): number {
  return Math.min(raw, max);
}

function normalizeName(value: string | null | undefined): string {
  return (value ?? "").trim().toLowerCase();
}

export interface BonusExtrasReviewParticipant {
  userId: number;
  userLabel: string;
  topScorer: string | null;
  topScorerCorrect: boolean | null;
  topScorerExactMatch: boolean;
  topAssister: string | null;
  topAssisterCorrect: boolean | null;
  topAssisterExactMatch: boolean;
}

export interface BonusExtrasReview {
  topScorer: string | null;
  topAssister: string | null;
  participants: BonusExtrasReviewParticipant[];
}

/** Goleador/asistidor reales + lo que escribió cada participante, para revisión manual del admin. */
export async function getBonusExtrasReview(): Promise<BonusExtrasReview> {
  const official = await getOfficialBonusResults();
  const offScorer = normalizeName(official.topScorer);
  const offAssister = normalizeName(official.topAssister);
  const { rows } = await pool.query(
    `SELECT u.id AS user_id, u.display_name, u.email,
            bp.top_scorer, bp.top_scorer_correct,
            bp.top_assister, bp.top_assister_correct
     FROM users u
     LEFT JOIN bonus_predictions bp ON bp.user_id = u.id
     WHERE u.role = 'USER' AND u.is_active = TRUE
     ORDER BY u.display_name NULLS LAST, u.email`
  );
  return {
    topScorer: official.topScorer ?? null,
    topAssister: official.topAssister ?? null,
    participants: rows.map((row) => {
      const scorer = (row.top_scorer as string | null) ?? null;
      const assister = (row.top_assister as string | null) ?? null;
      return {
        userId: Number(row.user_id),
        userLabel: String(row.display_name ?? row.email ?? row.user_id),
        topScorer: scorer,
        topScorerCorrect: (row.top_scorer_correct as boolean | null) ?? null,
        topScorerExactMatch: offScorer.length > 0 && normalizeName(scorer) === offScorer,
        topAssister: assister,
        topAssisterCorrect: (row.top_assister_correct as boolean | null) ?? null,
        topAssisterExactMatch: offAssister.length > 0 && normalizeName(assister) === offAssister
      };
    })
  };
}

export interface BonusExtrasMark {
  userId: number;
  topScorerCorrect: boolean | null;
  topAssisterCorrect: boolean | null;
}

/** Guarda, por participante, si acertó goleador y/o máximo asistidor. */
export async function saveBonusExtrasMarks(marks: BonusExtrasMark[]): Promise<number> {
  let updated = 0;
  for (const mark of marks) {
    const result = await pool.query(
      `UPDATE bonus_predictions
       SET top_scorer_correct = $2, top_assister_correct = $3
       WHERE user_id = $1`,
      [mark.userId, mark.topScorerCorrect, mark.topAssisterCorrect]
    );
    updated += result.rowCount ?? 0;
  }
  return updated;
}

/**
 * Compara ids de equipo que pueden llegar como string (node-pg devuelve BIGINT como string)
 * o como número (JSON de resultados oficiales). Un === directo entre ambos siempre da falso.
 */
export function sameTeamId(a: unknown, b: unknown): boolean {
  if (a == null || b == null) return false;
  const na = Number(a);
  const nb = Number(b);
  return !Number.isNaN(na) && na > 0 && na === nb;
}

function parseIdArray(raw: unknown): number[] {
  if (!Array.isArray(raw)) return [];
  return raw.map((v) => Number(v)).filter((id) => id > 0 && !Number.isNaN(id));
}

function sameIdSet(a: number[], b: number[]): boolean {
  if (a.length !== b.length) return false;
  const sortedA = [...a].sort((x, y) => x - y);
  const sortedB = [...b].sort((x, y) => x - y);
  return sortedA.every((id, i) => id === sortedB[i]);
}

function formatTeamList(names: string[]): string {
  return names.length > 0 ? names.join(", ") : "(ninguno)";
}

export interface TeamPickComparison {
  userId: number;
  userLabel: string;
  predictedIds: number[];
  predictedNames: string[];
  officialIds: number[];
  officialNames: string[];
  hitIds: number[];
  hitNames: string[];
  exactMatch: boolean;
  hits: number;
  points: number;
  hasPrediction: boolean;
}

export interface CalculateBonusScoresResult {
  usersScored: number;
  officialFinalists: { ids: number[]; names: string[] };
  officialSemifinalists: { ids: number[]; names: string[] };
  finalistComparisons: TeamPickComparison[];
  semifinalistComparisons: TeamPickComparison[];
}

async function loadTeamNameMap(ids: number[]): Promise<Map<number, string>> {
  const map = new Map<number, string>();
  if (ids.length === 0) return map;
  const { rows } = await pool.query<{ id: number; name: string }>(
    `SELECT id, name FROM teams WHERE id = ANY($1::bigint[])`,
    [ids]
  );
  for (const row of rows) {
    map.set(Number(row.id), row.name);
  }
  return map;
}

function teamNamesForIds(ids: number[], nameMap: Map<number, string>): string[] {
  return ids.map((id) => nameMap.get(id) ?? `#${id}`);
}

function buildTeamPickComparison(
  userId: number,
  userLabel: string,
  predictedIds: number[],
  officialIds: number[],
  pointsPerHit: number,
  maxPoints: number,
  nameMap: Map<number, string>,
  hasPrediction: boolean
): TeamPickComparison {
  const hitIds = predictedIds.filter((id) => officialIds.includes(id));
  const hits = hitIds.length;
  const points =
    hasPrediction && officialIds.length > 0 ? capPoints(hits * pointsPerHit, maxPoints) : 0;
  return {
    userId,
    userLabel,
    predictedIds,
    predictedNames: teamNamesForIds(predictedIds, nameMap),
    officialIds,
    officialNames: teamNamesForIds(officialIds, nameMap),
    hitIds,
    hitNames: teamNamesForIds(hitIds, nameMap),
    exactMatch: hasPrediction && officialIds.length > 0 && sameIdSet(predictedIds, officialIds),
    hits,
    points,
    hasPrediction
  };
}

export interface PrizeAllocation {
  /** matches.id → puntos de esta categoría asignados a ese partido. */
  byMatch: Map<number, number>;
  /** Puntos de equipos sin partido de origen conocido: van al cuadro de bonus como antes. */
  unsourced: number;
}

/**
 * Reparte los puntos de una categoría (semifinalistas/finalistas) entre los partidos que
 * consagraron a cada equipo acertado, respetando el tope total de la categoría. Los aciertos
 * con partido conocido se pagan primero (en orden de partido) para que el tope sea determinista.
 */
export function allocatePrizePointsByMatch(
  hitIds: number[],
  sources: Record<string, number>,
  pointsPerHit: number,
  maxPoints: number
): PrizeAllocation {
  const byMatch = new Map<number, number>();
  let unsourced = 0;
  let remaining = maxPoints;
  const ordered = [...hitIds].sort(
    (a, b) =>
      (sources[a] ?? Number.MAX_SAFE_INTEGER) - (sources[b] ?? Number.MAX_SAFE_INTEGER) || a - b
  );
  for (const teamId of ordered) {
    const pts = Math.min(pointsPerHit, remaining);
    if (pts <= 0) break;
    remaining -= pts;
    const matchId = sources[teamId];
    if (matchId != null) {
      byMatch.set(matchId, (byMatch.get(matchId) ?? 0) + pts);
    } else {
      unsourced += pts;
    }
  }
  return { byMatch, unsourced };
}

function logTeamPickComparisons(
  category: string,
  official: { ids: number[]; names: string[] },
  comparisons: TeamPickComparison[]
): void {
  console.log(
    `[bonuses] ${category} oficiales: [${formatTeamList(official.names)}] (ids: ${official.ids.join(", ") || "—"})`
  );
  for (const cmp of comparisons) {
    if (!cmp.hasPrediction) {
      console.log(
        `[bonuses] ${category} usuario ${cmp.userLabel} (id=${cmp.userId}): sin predicción → omitido`
      );
      continue;
    }
    const status = cmp.exactMatch ? "IGUAL" : cmp.hits > 0 ? "PARCIAL" : "SIN ACERTOS";
    console.log(
      `[bonuses] ${category} usuario ${cmp.userLabel} (id=${cmp.userId}): ` +
        `predicho [${formatTeamList(cmp.predictedNames)}] vs oficial [${formatTeamList(cmp.officialNames)}] → ` +
        `aciertos ${cmp.hits}/${cmp.officialIds.length} (${status}), +${cmp.points} pts`
    );
  }
}

export async function calculateBonusScores(): Promise<CalculateBonusScoresResult> {
  const official = await getOfficialBonusResults();
  const rules = await loadOfficialScoringRules();
  const preds = await pool.query(
    `SELECT bp.*, u.display_name, u.email
     FROM bonus_predictions bp
     JOIN users u ON u.id = bp.user_id
     ORDER BY u.display_name NULLS LAST, u.email`
  );

  const offFinal = parseIdArray(official.finalistTeamIds);
  const offSemi = parseIdArray(official.semifinalistTeamIds);
  const allTeamIds = new Set<number>([...offFinal, ...offSemi]);
  for (const row of preds.rows) {
    for (const id of parseIdArray(row.finalist_team_ids)) allTeamIds.add(id);
    for (const id of parseIdArray(row.semifinalist_team_ids)) allTeamIds.add(id);
    if (official.championTeamId) allTeamIds.add(Number(official.championTeamId));
    if (official.runnerUpTeamId) allTeamIds.add(Number(official.runnerUpTeamId));
  }
  const nameMap = await loadTeamNameMap([...allTeamIds]);

  const officialFinalists = {
    ids: offFinal,
    names: teamNamesForIds(offFinal, nameMap)
  };
  const officialSemifinalists = {
    ids: offSemi,
    names: teamNamesForIds(offSemi, nameMap)
  };

  if (official.championTeamId || official.runnerUpTeamId) {
    const winnerIds = [official.championTeamId, official.runnerUpTeamId]
      .filter((id): id is number => id != null && id > 0)
      .map(Number);
    const winnerNames = teamNamesForIds(winnerIds, nameMap);
    const winnersInFinalists =
      winnerIds.length === 0 || winnerIds.every((id) => offFinal.includes(id));
    console.log(
      `[bonuses] Campeón/subcampeón oficiales: [${formatTeamList(winnerNames)}] → ` +
        `${winnersInFinalists ? "coinciden con finalistas oficiales" : "NO coinciden con finalistas oficiales"} ` +
        `[${formatTeamList(officialFinalists.names)}]`
    );
  }

  const finalistComparisons: TeamPickComparison[] = [];
  const semifinalistComparisons: TeamPickComparison[] = [];
  let usersScored = 0;

  const semiSources = official.semifinalistSourceMatchIds ?? {};
  const finalSources = official.finalistSourceMatchIds ?? {};
  // Los premios por partido se reconstruyen completos en cada recálculo: así una corrección de
  // resultado también revoca premios que ya no correspondan.
  await pool.query(`DELETE FROM prediction_scores WHERE source_type = 'BRACKET_PRIZE'`);

  for (const row of preds.rows) {
    const userLabel = String(row.display_name ?? row.email ?? row.user_id);
    let points = 0;
    const breakdown: Record<string, number> = {};
    const prizeByMatch = new Map<number, Record<string, number>>();
    const addPrize = (alloc: PrizeAllocation, key: "semifinalists" | "finalists") => {
      for (const [matchId, pts] of alloc.byMatch) {
        const slot = prizeByMatch.get(matchId) ?? {};
        slot[key] = (slot[key] ?? 0) + pts;
        prizeByMatch.set(matchId, slot);
      }
    };
    // Premio de un solo equipo (campeón, subcampeón, tercer puesto): va al partido que lo
    // consagró; si no se conoce (resultado fijado a mano), cae al cuadro de bonus como antes.
    const addSinglePrize = (matchId: number | null | undefined, key: string, pts: number) => {
      if (matchId != null) {
        const slot = prizeByMatch.get(Number(matchId)) ?? {};
        slot[key] = (slot[key] ?? 0) + pts;
        prizeByMatch.set(Number(matchId), slot);
      } else {
        breakdown[key] = pts;
        points += pts;
      }
    };

    if (sameTeamId(row.champion_team_id, official.championTeamId)) {
      addSinglePrize(official.championMatchId, "champion", rules.champion_points);
    }
    if (sameTeamId(row.runner_up_team_id, official.runnerUpTeamId)) {
      addSinglePrize(official.championMatchId, "runnerUp", rules.runner_up_points);
    }
    if (sameTeamId(row.third_place_team_id, official.thirdPlaceTeamId)) {
      addSinglePrize(official.thirdPlaceMatchId, "thirdPlace", rules.third_place_points);
    }

    const predSemi = parseIdArray(row.semifinalist_team_ids);
    if (offSemi.length > 0) {
      const semiCmp = buildTeamPickComparison(
        row.user_id,
        userLabel,
        predSemi,
        offSemi,
        rules.semifinalist_points,
        rules.semifinalist_max_points,
        nameMap,
        predSemi.length > 0
      );
      semifinalistComparisons.push(semiCmp);
      if (semiCmp.points > 0) {
        const alloc = allocatePrizePointsByMatch(
          semiCmp.hitIds,
          semiSources,
          rules.semifinalist_points,
          rules.semifinalist_max_points
        );
        addPrize(alloc, "semifinalists");
        if (alloc.unsourced > 0) {
          breakdown.semifinalists = alloc.unsourced;
          points += alloc.unsourced;
        }
      }
    }

    const predFinal = parseIdArray(row.finalist_team_ids);
    if (offFinal.length > 0) {
      const finalCmp = buildTeamPickComparison(
        row.user_id,
        userLabel,
        predFinal,
        offFinal,
        rules.finalist_points,
        rules.finalist_max_points,
        nameMap,
        predFinal.length > 0
      );
      finalistComparisons.push(finalCmp);
      if (finalCmp.points > 0) {
        const alloc = allocatePrizePointsByMatch(
          finalCmp.hitIds,
          finalSources,
          rules.finalist_points,
          rules.finalist_max_points
        );
        addPrize(alloc, "finalists");
        if (alloc.unsourced > 0) {
          breakdown.finalists = alloc.unsourced;
          points += alloc.unsourced;
        }
      }
    }

    // Goleador y máximo asistidor: el admin marca manualmente quién acertó
    // (las personas escriben el nombre de formas distintas), así que el puntaje
    // depende de la marca, no de un match de texto exacto.
    if (official.topScorer?.trim() && row.top_scorer_correct === true) {
      breakdown.topScorer = rules.top_scorer_points;
      points += rules.top_scorer_points;
    }

    if (official.topAssister?.trim() && row.top_assister_correct === true) {
      breakdown.topAssister = rules.top_assister_points;
      points += rules.top_assister_points;
    }

    await pool.query(
      `INSERT INTO prediction_scores (user_id, source_type, source_id, points, breakdown)
      VALUES ($1, 'BONUSES', 0, $2, $3::jsonb)
      ON CONFLICT (user_id, source_type, source_id)
      DO UPDATE SET points = EXCLUDED.points, breakdown = EXCLUDED.breakdown, updated_at = NOW()`,
      [row.user_id, points, JSON.stringify(breakdown)]
    );

    // Premio del cuadro asignado al partido que lo consagró (se ve en el desglose del partido).
    for (const [matchId, prizeBreakdown] of prizeByMatch) {
      const prizePoints = Object.values(prizeBreakdown).reduce((acc, v) => acc + v, 0);
      if (prizePoints <= 0) continue;
      await pool.query(
        `INSERT INTO prediction_scores (user_id, source_type, source_id, points, breakdown)
        VALUES ($1, 'BRACKET_PRIZE', $2, $3, $4::jsonb)
        ON CONFLICT (user_id, source_type, source_id)
        DO UPDATE SET points = EXCLUDED.points, breakdown = EXCLUDED.breakdown, updated_at = NOW()`,
        [row.user_id, matchId, prizePoints, JSON.stringify(prizeBreakdown)]
      );
    }
    usersScored += 1;
  }

  console.log(`[bonuses] Calculando puntos cuadro/premios para ${usersScored} usuarios`);
  logTeamPickComparisons("Finalistas", officialFinalists, finalistComparisons);
  logTeamPickComparisons("Semifinalistas", officialSemifinalists, semifinalistComparisons);

  return {
    usersScored,
    officialFinalists,
    officialSemifinalists,
    finalistComparisons,
    semifinalistComparisons
  };
}
