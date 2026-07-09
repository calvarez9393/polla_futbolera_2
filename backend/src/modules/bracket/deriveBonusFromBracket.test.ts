import { describe, expect, it } from "vitest";
import { buildDerivedBracketBonusPicks, buildOfficialBracketBonusPicks } from "./deriveBonusFromBracket.js";
import type { KnockoutMatchRow, UserPredictionRow } from "./knockoutBracketLogic.js";
import { resolveKnockoutBracketTeams, resolveOfficialKnockoutBracketTeams } from "./knockoutBracketLogic.js";

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

  it("no infiere finalistas desde el cuadro oficial si el usuario no predijo eliminatorias", () => {
    const rows = [
      koRow(3, 101, E, F, "SF"),
      koRow(4, 102, A, B, "SF"),
      koRow(5, 104, E, F, "F")
    ];
    const preds = new Map<number, UserPredictionRow>();
    const resolved = resolveKnockoutBracketTeams(rows, preds, TBD);
    const derived = buildDerivedBracketBonusPicks(
      rows,
      roundMap([
        [3, "SF"],
        [4, "SF"],
        [5, "F"]
      ]),
      resolved,
      preds,
      TBD
    );

    expect(derived.semifinalistTeamIds).toEqual([]);
    expect(derived.finalistTeamIds).toEqual([]);
    expect(derived.championTeamId).toBeNull();
    expect(derived.runnerUpTeamId).toBeNull();
  });
});

describe("buildOfficialBracketBonusPicks", () => {
  const roundMapOfficial = roundMap([
    [1, "R4"],
    [2, "R4"],
    [3, "SF"],
    [4, "SF"],
    [5, "F"]
  ]);

  it("con un solo cuartos jugado: su ganador es semifinalista, NO finalista; el resto nada", () => {
    const rows: KnockoutMatchRow[] = [
      { ...koRow(1, 97, A, B, "R4"), status: "FINISHED", home_score: 2, away_score: 1, winner_team_id: A },
      koRow(2, 98, C, D, "R4"),
      koRow(3, 101, TBD, TBD, "SF"),
      koRow(4, 102, TBD, TBD, "SF"),
      koRow(5, 104, TBD, TBD, "F")
    ];
    const resolved = resolveOfficialKnockoutBracketTeams(rows, TBD);
    const official = buildOfficialBracketBonusPicks(rows, roundMapOfficial, resolved, TBD);

    expect(official.semifinalistTeamIds).toEqual([A]);
    expect(official.finalistTeamIds).toEqual([]);
    expect(official.championTeamId).toBeNull();
    expect(official.runnerUpTeamId).toBeNull();
    // El premio de semifinalista queda asignado al partido de cuartos que ganó (id 1).
    expect(official.semifinalistSourceMatchIds).toEqual({ [String(A)]: 1 });
    expect(official.finalistSourceMatchIds).toEqual({});
  });

  it("los participantes de cuartos sin jugar no cuentan como semifinalistas ni finalistas", () => {
    const rows: KnockoutMatchRow[] = [
      koRow(1, 97, A, B, "R4"),
      koRow(2, 98, C, D, "R4"),
      koRow(3, 101, TBD, TBD, "SF"),
      koRow(5, 104, TBD, TBD, "F")
    ];
    const resolved = resolveOfficialKnockoutBracketTeams(rows, TBD);
    const official = buildOfficialBracketBonusPicks(rows, roundMapOfficial, resolved, TBD);

    expect(official.semifinalistTeamIds).toEqual([]);
    expect(official.finalistTeamIds).toEqual([]);
  });

  it("solo el ganador de la semifinal pasa a finalista; el perdedor (tercer puesto) no", () => {
    const rows: KnockoutMatchRow[] = [
      { ...koRow(1, 97, A, B, "R4"), status: "FINISHED", home_score: 2, away_score: 1, winner_team_id: A },
      { ...koRow(2, 98, C, D, "R4"), status: "FINISHED", home_score: 0, away_score: 1, winner_team_id: D },
      { ...koRow(3, 101, TBD, TBD, "SF"), status: "FINISHED", home_score: 1, away_score: 0 },
      koRow(5, 104, TBD, TBD, "F")
    ];
    const resolved = resolveOfficialKnockoutBracketTeams(rows, TBD);
    // La semifinal 101 se resuelve A (ganador 97) vs D (ganador 98) y la gana A por marcador.
    const official = buildOfficialBracketBonusPicks(rows, roundMapOfficial, resolved, TBD);

    expect(official.semifinalistTeamIds).toEqual(expect.arrayContaining([A, D]));
    expect(official.finalistTeamIds).toEqual([A]);
    expect(official.championTeamId).toBeNull();
    // Cada premio queda asignado al partido que lo consagró: semifinalista → su cuartos,
    // finalista → la semifinal que ganó.
    expect(official.semifinalistSourceMatchIds).toEqual({ [String(A)]: 1, [String(D)]: 2 });
    expect(official.finalistSourceMatchIds).toEqual({ [String(A)]: 3 });
  });
});
