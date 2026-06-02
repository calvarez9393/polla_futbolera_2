import { describe, expect, it } from "vitest";
import {
  KNOCKOUT_SLOT_FEEDS,
  matchOutcome,
  parseSlotFeed,
  resolveKnockoutBracketTeams
} from "./knockoutBracketLogic.js";
import type { KnockoutMatchRow } from "./knockoutBracketLogic.js";

const TBD = 1;
const A = 10;
const B = 11;
const C = 12;
const D = 13;

function koRow(
  id: number,
  num: number,
  home: number,
  away: number,
  status: string,
  extra: Partial<KnockoutMatchRow> = {}
): KnockoutMatchRow {
  return {
    id,
    external_id: `wc2026-ko-${num}`,
    status,
    home_team_id: home,
    away_team_id: away,
    home_score: null,
    away_score: null,
    winner_team_id: null,
    ...extra
  };
}

describe("parseSlotFeed", () => {
  it("parsea ranuras FIFA", () => {
    expect(parseSlotFeed("Ganador partido 74")).toEqual({ type: "winner", matchNum: 74 });
    expect(parseSlotFeed("Ganador octavos 89")).toEqual({ type: "winner", matchNum: 89 });
    expect(parseSlotFeed("Perdedor semifinal 2")).toEqual({ type: "loser", matchNum: 102 });
  });
});

describe("resolveKnockoutBracketTeams", () => {
  it("propaga ganador desde marcador predicho sin campo avanza", () => {
    const rows = [
      koRow(1, 74, A, B, "NOT_STARTED"),
      koRow(2, 89, TBD, TBD, "NOT_STARTED")
    ];
    const preds = new Map([
      [1, { predicted_home_score: 2, predicted_away_score: 1, predicted_advancing_team_id: null }]
    ]);
    const resolved = resolveKnockoutBracketTeams(rows, preds, TBD);
    expect(resolved.get(89)?.homeTeamId).toBe(A);
  });

  it("propaga ganador simulado del usuario a octavos", () => {
    expect(KNOCKOUT_SLOT_FEEDS[89]?.home?.matchNum).toBe(74);

    const rows = [
      koRow(1, 74, A, B, "NOT_STARTED"),
      koRow(2, 89, TBD, TBD, "NOT_STARTED")
    ];
    const preds = new Map([
      [1, { predicted_home_score: 2, predicted_away_score: 0, predicted_advancing_team_id: A }]
    ]);

    const resolved = resolveKnockoutBracketTeams(rows, preds, TBD);
    expect(resolved.get(89)?.homeTeamId).toBe(A);
  });

  it("usa resultado oficial finalizado", () => {
    const rows = [
      koRow(1, 74, A, B, "FINISHED", {
        home_score: 1,
        away_score: 0,
        winner_team_id: A
      }),
      koRow(2, 89, TBD, C, "NOT_STARTED")
    ];

    const resolved = resolveKnockoutBracketTeams(rows, new Map(), TBD);
    expect(resolved.get(89)?.homeTeamId).toBe(A);
  });

  it("propaga ganador en empate con penales a octavos", () => {
    const rows = [
      koRow(1, 74, A, B, "NOT_STARTED"),
      koRow(2, 89, TBD, TBD, "NOT_STARTED")
    ];
    const preds = new Map([
      [1, { predicted_home_score: 1, predicted_away_score: 1, predicted_advancing_team_id: A }]
    ]);
    const resolved = resolveKnockoutBracketTeams(rows, preds, TBD);
    expect(resolved.get(89)?.homeTeamId).toBe(A);
  });

  it("propaga empate con penales cuando el id viene como string (node-pg)", () => {
    const row = koRow(1, 74, A, B, "NOT_STARTED");
    const pred = {
      predicted_home_score: 1,
      predicted_away_score: 1,
      predicted_advancing_team_id: String(A) as unknown as number
    };
    expect(matchOutcome(row, pred, A, B, TBD).winnerId).toBe(A);

    const rows = [row, koRow(2, 89, TBD, TBD, "NOT_STARTED")];
    const preds = new Map([[1, pred]]);
    expect(resolveKnockoutBracketTeams(rows, preds, TBD).get(89)?.homeTeamId).toBe(A);
  });

  it("requiere el partido alimentador en el array para propagar", () => {
    const rows = [koRow(2, 89, TBD, TBD, "NOT_STARTED")];
    const preds = new Map([
      [1, { predicted_home_score: 2, predicted_away_score: 1, predicted_advancing_team_id: null }]
    ]);

    const resolved = resolveKnockoutBracketTeams(rows, preds, TBD);
    expect(resolved.get(89)?.homeTeamId).toBe(TBD);
  });

  it("propaga perdedor de semifinal al tercer puesto", () => {
    const rows = [
      koRow(1, 101, A, B, "FINISHED", { home_score: 2, away_score: 1, winner_team_id: A }),
      koRow(2, 103, TBD, TBD, "NOT_STARTED")
    ];
    const resolved = resolveKnockoutBracketTeams(rows, new Map(), TBD);
    expect(resolved.get(103)?.homeTeamId).toBe(B);
  });
});

describe("matchOutcome", () => {
  it("deduce ganador desde marcador", () => {
    const row = koRow(1, 73, C, D, "FINISHED", { home_score: 3, away_score: 1 });
    expect(matchOutcome(row, null, C, D, TBD).winnerId).toBe(C);
  });
});
