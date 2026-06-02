import type { FifaQualifiersResult } from "../standings/simulate.js";
import { groupLetterFromName } from "./groupLetter.js";
import { WC2026_R32_FIXTURES_RAW } from "./wc2026R32Fixtures.js";

/** Orden FIFA para asignar 3º clasificados a ranuras (partidos con tercero). */
const THIRD_SLOT_MATCH_ORDER = [74, 77, 79, 80, 81, 82, 85, 87] as const;

function rankThirds(
  thirds: FifaQualifiersResult["bestThirds"]
): FifaQualifiersResult["bestThirds"] {
  return [...thirds].sort((a, b) => {
    if (b.points !== a.points) return b.points - a.points;
    if (b.goalDiff !== a.goalDiff) return b.goalDiff - a.goalDiff;
    if (b.goalsFor !== a.goalsFor) return b.goalsFor - a.goalsFor;
    if (b.played !== a.played) return b.played - a.played;
    return a.groupName.localeCompare(b.groupName);
  });
}

/**
 * Asigna los 8 mejores terceros a las 8 ranuras de dieciseisavos.
 * Primero intenta con el top 8 FIFA; si una ranura no tiene candidato, usa el siguiente 3º del ranking global.
 */
export function assignThirdPlacesToR32Slots(
  fifa: FifaQualifiersResult
): Map<number, number> {
  const byMatch = new Map<number, number>();
  const usedTeamIds = new Set<number>();

  const bestThirdIds = new Set(fifa.bestThirds.map((t) => t.teamId));
  const rankedBest = rankThirds(fifa.bestThirds);
  const rankedAll = rankThirds(fifa.allThirdsRanked);

  const pickCandidate = (allowed: Set<string>, preferBestOnly: boolean) => {
    const pools = preferBestOnly
      ? [rankedBest]
      : [rankedBest, rankedAll.filter((t) => !bestThirdIds.has(t.teamId))];

    for (const list of pools) {
      const found = list.find(
        (t) => allowed.has(groupLetterFromName(t.groupName)) && !usedTeamIds.has(t.teamId)
      );
      if (found) return found;
    }
    return null;
  };

  for (const matchNum of THIRD_SLOT_MATCH_ORDER) {
    const fx = WC2026_R32_FIXTURES_RAW.find((f) => f.num === matchNum);
    if (!fx?.thirdAwayGroups?.length) continue;

    const allowed = new Set(fx.thirdAwayGroups.map((g) => g.toUpperCase()));
    const candidate = pickCandidate(allowed, true) ?? pickCandidate(allowed, false);
    if (candidate) {
      byMatch.set(matchNum, candidate.teamId);
      usedTeamIds.add(candidate.teamId);
    }
  }

  return byMatch;
}

export function describeThirdSlot(matchNum: number): string {
  const fx = WC2026_R32_FIXTURES_RAW.find((f) => f.num === matchNum);
  return fx?.awaySlot ?? `Partido ${matchNum}`;
}
