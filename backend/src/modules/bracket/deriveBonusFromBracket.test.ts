import { describe, expect, it } from "vitest";
import { buildDerivedBracketBonusPicks } from "./deriveBonusFromBracket.js";
import type { KnockoutMatchRow, UserPredictionRow } from "./knockoutBracketLogic.js";
import { resolveKnockoutBracketTeams } from "./knockoutBracketLogic.js";

const TBD = 1;
const A = 10;
const B = 11;
const C = 12;
const D = 13;
const E = 14;
const F = 15;

function koRow(id: number, num: number, home: number, away: number, roundKey: string): KnockoutMatchRow {
  return {
    id,
    external_id: `wc2026-ko-${num}`,
    status: "NOT_STARTED",
    home_team_id: home,
    away_team_id: away,
    home_score: null,
    away_score: null,
    winner_team_id: null
  };
}

function roundMap(entries: Array<[number, string]>): Map<number, string> {
  return new Map(entries);
}

describe("buildDerivedBracketBonusPicks", () => {
  it("obtiene semifinalistas desde ganadores de cuartos aunque SF aún tenga TBD", () => {
    const rows = [
      koRow(1, 97, TBD, TBD, "R4"),
      koRow(2, 98, TBD, TBD, "R4"),
      koRow(3, 101, TBD, TBD, "SF"),
      koRow(4, 102, TBD, TBD, "SF")
    ];
    rows[0] = { ...rows[0], home_team_id: A, away_team_id: B };
    rows[1] = { ...rows[1], home_team_id: C, away_team_id: D };

    const preds = new Map<number, UserPredictionRow>([
      [1, { predicted_home_score: 2, predicted_away_score: 0, predicted_advancing_team_id: A }],
      [2, { predicted_home_score: 1, predicted_away_score: 0, predicted_advancing_team_id: C }]
    ]);

    const resolved = resolveKnockoutBracketTeams(rows, preds, TBD);
    const derived = buildDerivedBracketBonusPicks(
      rows,
      roundMap([
        [1, "R4"],
        [2, "R4"],
        [3, "SF"],
        [4, "SF"]
      ]),
      resolved,
      preds,
      TBD
    );

    expect(derived.semifinalistTeamIds).toEqual(expect.arrayContaining([A, C]));
    expect(derived.semifinalistTeamIds.length).toBeGreaterThanOrEqual(2);
  });

  it("obtiene campeón y subcampeón desde predicción de la final", () => {
    const rows = [
      koRow(5, 104, E, F, "F")
    ];
    const preds = new Map<number, UserPredictionRow>([
      [5, { predicted_home_score: 3, predicted_away_score: 1, predicted_advancing_team_id: E }]
    ]);
    const resolved = resolveKnockoutBracketTeams(rows, preds, TBD);
    const derived = buildDerivedBracketBonusPicks(
      rows,
      roundMap([[5, "F"]]),
      resolved,
      preds,
      TBD
    );

    expect(derived.championTeamId).toBe(E);
    expect(derived.runnerUpTeamId).toBe(F);
    expect(derived.finalistTeamIds).toEqual(expect.arrayContaining([E, F]));
  });
});
