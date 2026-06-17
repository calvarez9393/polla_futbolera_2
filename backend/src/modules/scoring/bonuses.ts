import { pool } from "../../db/pool.js";
import { getSetting, setSetting } from "../settings/service.js";
import { loadOfficialScoringRules } from "./loadRules.js";

export interface OfficialBonusResults {
  championTeamId?: number | null;
  runnerUpTeamId?: number | null;
  thirdPlaceTeamId?: number | null;
  semifinalistTeamIds?: number[];
  finalistTeamIds?: number[];
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

  for (const row of preds.rows) {
    const userLabel = String(row.display_name ?? row.email ?? row.user_id);
    let points = 0;
    const breakdown: Record<string, number> = {};

    if (official.championTeamId && row.champion_team_id === official.championTeamId) {
      breakdown.champion = rules.champion_points;
      points += rules.champion_points;
    }
    if (official.runnerUpTeamId && row.runner_up_team_id === official.runnerUpTeamId) {
      breakdown.runnerUp = rules.runner_up_points;
      points += rules.runner_up_points;
    }
    if (official.thirdPlaceTeamId && row.third_place_team_id === official.thirdPlaceTeamId) {
      breakdown.thirdPlace = rules.third_place_points;
      points += rules.third_place_points;
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
      if (semiCmp.points > 0) breakdown.semifinalists = semiCmp.points;
      points += semiCmp.points;
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
      if (finalCmp.points > 0) breakdown.finalists = finalCmp.points;
      points += finalCmp.points;
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
