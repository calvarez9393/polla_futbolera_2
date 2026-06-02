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

export async function calculateBonusScores(): Promise<{ usersScored: number }> {
  const official = await getOfficialBonusResults();
  const rules = await loadOfficialScoringRules();
  const preds = await pool.query("SELECT * FROM bonus_predictions");
  let usersScored = 0;

  for (const row of preds.rows) {
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

    const predSemi: number[] = row.semifinalist_team_ids ?? [];
    const offSemi = official.semifinalistTeamIds ?? [];
    if (offSemi.length > 0) {
      const semiHits = predSemi.filter((id) => offSemi.includes(id)).length;
      const semiPts = capPoints(semiHits * rules.semifinalist_points, rules.semifinalist_max_points);
      if (semiPts > 0) breakdown.semifinalists = semiPts;
      points += semiPts;
    }

    const predFinal: number[] = row.finalist_team_ids ?? [];
    const offFinal = official.finalistTeamIds ?? [];
    if (offFinal.length > 0) {
      const finalHits = predFinal.filter((id) => offFinal.includes(id)).length;
      const finalPts = capPoints(finalHits * rules.finalist_points, rules.finalist_max_points);
      if (finalPts > 0) breakdown.finalists = finalPts;
      points += finalPts;
    }

    if (official.topScorer && row.top_scorer?.trim().toLowerCase() === official.topScorer.trim().toLowerCase()) {
      breakdown.topScorer = rules.top_scorer_points;
      points += rules.top_scorer_points;
    }

    if (
      official.topAssister &&
      row.top_assister?.trim().toLowerCase() === official.topAssister.trim().toLowerCase()
    ) {
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

  return { usersScored };
}
