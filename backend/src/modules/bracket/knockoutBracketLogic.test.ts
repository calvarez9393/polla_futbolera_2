import { describe, expect, it } from "vitest";
import {
  KNOCKOUT_SLOT_FEEDS,
  matchOutcomeFromPrediction,
  matchOutcomeOfficial,
  parseSlotFeed,
  resolveKnockoutBracketTeams,
  resolveOfficialKnockoutBracketTeams
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

  it("usa clasificados reales en R16 y simula octavos desde predicción del usuario", () => {
    const rows = [
      koRow(1, 74, TBD, TBD, "NOT_STARTED"),
      koRow(2, 89, TBD, TBD, "NOT_STARTED")
    ];
    const r16Official = new Map([[74, { homeTeamId: A, awayTeamId: B }]]);
    const preds = new Map([
      [1, { predicted_home_score: 0, predicted_away_score: 1, predicted_advancing_team_id: B }]
    ]);
    const resolved = resolveKnockoutBracketTeams(rows, preds, TBD, r16Official);
    expect(resolved.get(74)?.homeTeamId).toBe(A);
    expect(resolved.get(74)?.awayTeamId).toBe(B);
    expect(resolved.get(89)?.homeTeamId).toBe(B);
  });

  it("no sobrescribe el cuadro del usuario con resultado oficial", () => {
    const rows = [
      koRow(1, 74, A, B, "FINISHED", {
        home_score: 1,
        away_score: 0,
        winner_team_id: A
      }),
      koRow(2, 89, TBD, C, "NOT_STARTED")
    ];
    const preds = new Map([
      [1, { predicted_home_score: 0, predicted_away_score: 1, predicted_advancing_team_id: B }]
    ]);

    const resolved = resolveKnockoutBracketTeams(rows, preds, TBD);
    expect(resolved.get(89)?.homeTeamId).toBe(B);
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
    expect(matchOutcomeFromPrediction(pred, A, B, TBD).winnerId).toBe(A);

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

  it("propaga perdedor de semifinal al tercer puesto según predicción del usuario", () => {
    const rows = [
      koRow(1, 101, A, B, "NOT_STARTED"),
      koRow(2, 103, TBD, TBD, "NOT_STARTED")
    ];
    const preds = new Map([
      [1, { predicted_home_score: 2, predicted_away_score: 1, predicted_advancing_team_id: A }]
    ]);
    const resolved = resolveKnockoutBracketTeams(rows, preds, TBD);
    expect(resolved.get(103)?.homeTeamId).toBe(B);
  });
});

describe("matchOutcomeOfficial", () => {
  it("deduce ganador oficial desde marcador", () => {
    const row = koRow(1, 73, C, D, "FINISHED", { home_score: 3, away_score: 1 });
    expect(matchOutcomeOfficial(row, C, D, TBD).winnerId).toBe(C);
  });

  it("ignora un winner_team_id que ya no es participante y usa el marcador", () => {
    // Tras corregir un partido anterior, los participantes reales son B y C, pero quedó guardado
    // A (equipo viejo). El ganador debe derivarse del marcador entre B y C, no ser A.
    const row = koRow(1, 90, B, C, "FINISHED", { home_score: 2, away_score: 1, winner_team_id: A });
    expect(matchOutcomeOfficial(row, B, C, TBD).winnerId).toBe(B);
  });

  it("respeta el ganador en penales si sigue siendo participante", () => {
    const row = koRow(1, 90, B, C, "FINISHED", { home_score: 1, away_score: 1, winner_team_id: C });
    expect(matchOutcomeOfficial(row, B, C, TBD).winnerId).toBe(C);
  });
});

describe("resolveOfficialKnockoutBracketTeams (auto-sanación)", () => {
  it("repropaga semis cuando una corrección en octavos dejó huérfano al ganador de cuartos", () => {
    // Cadena octavos(89,90) → cuartos(97) → semifinal(101).
    // Antes de corregir: octavos 90 lo ganaba A, que jugó y ganó cuartos 97 y pasó a semis 101.
    // Tras corregir octavos 90 (ahora gana B), cuartos 97 pasa a ser C vs B, pero conservó su
    // marcador (C 2-1) y un winner_team_id = A que YA NO juega ahí. El fix debe recolocar 97 e
    // ignorar ese ganador huérfano para que a semis 101 pase C (ganador por marcador), no A.
    const rows = [
      koRow(1, 89, C, D, "FINISHED", { home_score: 2, away_score: 0, winner_team_id: C }),
      koRow(2, 90, A, B, "FINISHED", { home_score: 0, away_score: 1, winner_team_id: B }),
      koRow(3, 97, C, A, "FINISHED", { home_score: 2, away_score: 1, winner_team_id: A }),
      koRow(4, 101, A, TBD, "NOT_STARTED")
    ];
    const resolved = resolveOfficialKnockoutBracketTeams(rows, TBD);
    expect(resolved.get(97)?.homeTeamId).toBe(C); // ganador real de 89
    expect(resolved.get(97)?.awayTeamId).toBe(B); // ahora B (octavos 90 corregido), no A
    expect(resolved.get(101)?.homeTeamId).toBe(C); // ganador de 97 por marcador, ya no el huérfano A
  });
});
