import { describe, expect, it } from "vitest";
import { computeAdvanceOnlyPoints, computePredictionPoints } from "./rules.js";
import { DEFAULT_OFFICIAL_RULES } from "./rulesConfig.js";

const rules = DEFAULT_OFFICIAL_RULES;

describe("computePredictionPoints — Fase 1", () => {
  it("marcador exacto Colombia 2-1", () => {
    const result = computePredictionPoints({
      predictedHome: 2,
      predictedAway: 1,
      realHome: 2,
      realAway: 1,
      roundKey: "GROUP",
      rules
    });
    expect(result.points).toBe(10);
    expect(result.breakdown.winner).toBe(3);
    expect(result.breakdown.goalDiff).toBe(2);
    expect(result.breakdown.exactScore).toBe(5);
  });

  it("ganador y diferencia sin exacto", () => {
    const result = computePredictionPoints({
      predictedHome: 3,
      predictedAway: 1,
      realHome: 2,
      realAway: 0,
      roundKey: "GROUP",
      rules
    });
    expect(result.points).toBe(5);
  });

  it("ganador invertido no suma diferencia de goles", () => {
    const result = computePredictionPoints({
      predictedHome: 0,
      predictedAway: 1,
      realHome: 1,
      realAway: 0,
      roundKey: "GROUP",
      rules
    });
    expect(result.points).toBe(0);
    expect(result.breakdown.goalDiff).toBeUndefined();
  });

  it("empate sin exacto suma empate y diferencia", () => {
    const result = computePredictionPoints({
      predictedHome: 1,
      predictedAway: 1,
      realHome: 2,
      realAway: 2,
      roundKey: "GROUP",
      rules
    });
    expect(result.points).toBe(5);
    expect(result.breakdown.draw).toBe(3);
    expect(result.breakdown.goalDiff).toBe(2);
  });

  it("empate con marcador exacto suma empate, diferencia y exacto", () => {
    const result = computePredictionPoints({
      predictedHome: 1,
      predictedAway: 1,
      realHome: 1,
      realAway: 1,
      roundKey: "GROUP",
      rules
    });
    expect(result.points).toBe(10);
    expect(result.breakdown.draw).toBe(3);
    expect(result.breakdown.goalDiff).toBe(2);
    expect(result.breakdown.exactScore).toBe(5);
  });

  it("en 16avos el empate exacto sí suma diferencia de goles", () => {
    const result = computePredictionPoints({
      predictedHome: 0,
      predictedAway: 0,
      realHome: 0,
      realAway: 0,
      roundKey: "R16",
      rules
    });
    expect(result.points).toBe(10);
    expect(result.breakdown.draw).toBe(3);
    expect(result.breakdown.goalDiff).toBe(2);
    expect(result.breakdown.exactScore).toBe(5);
  });
});

describe("computeAdvanceOnlyPoints — cruce distinto al oficial", () => {
  it("acierta el equipo que avanza en octavos", () => {
    const result = computeAdvanceOnlyPoints({
      roundKey: "R8",
      predictedAdvancingTeamId: 10,
      winnerTeamId: 10,
      rules
    });
    expect(result).toEqual({ points: 8, breakdown: { advancing: 8 } });
  });

  it("ambos equipos distintos no suma puntos", () => {
    const result = computeAdvanceOnlyPoints({
      roundKey: "R8",
      predictedAdvancingTeamId: 7,
      winnerTeamId: 10,
      rules
    });
    expect(result).toBeNull();
  });

  it("dieciseisavos no tiene puntos de avance por partido", () => {
    const result = computeAdvanceOnlyPoints({
      roundKey: "R16",
      predictedAdvancingTeamId: 10,
      winnerTeamId: 10,
      rules
    });
    expect(result).toBeNull();
  });

  it("tolera ids como texto (PostgreSQL bigint)", () => {
    const result = computeAdvanceOnlyPoints({
      roundKey: "R4",
      predictedAdvancingTeamId: 10,
      winnerTeamId: Number("10"),
      rules
    });
    expect(result).toEqual({ points: 12, breakdown: { advancing: 12 } });
  });
});

describe("computePredictionPoints — Fase 2 octavos", () => {
  it("clasificado y marcador exacto suma también ganador y diferencia", () => {
    const result = computePredictionPoints({
      predictedHome: 2,
      predictedAway: 1,
      realHome: 2,
      realAway: 1,
      roundKey: "R8",
      predictedAdvancingTeamId: 10,
      winnerTeamId: 10,
      rules
    });
    expect(result.points).toBe(18);
    expect(result.breakdown.winner).toBe(3);
    expect(result.breakdown.goalDiff).toBe(2);
    expect(result.breakdown.advancing).toBe(8);
    expect(result.breakdown.exactScore).toBe(5);
  });

  it("acierta ganador y avance sin diferencia ni exacto", () => {
    const result = computePredictionPoints({
      predictedHome: 1,
      predictedAway: 0,
      realHome: 2,
      realAway: 0,
      roundKey: "R8",
      predictedAdvancingTeamId: 10,
      winnerTeamId: 10,
      rules
    });
    expect(result.points).toBe(11);
    expect(result.breakdown.winner).toBe(3);
    expect(result.breakdown.goalDiff).toBeUndefined();
    expect(result.breakdown.advancing).toBe(8);
  });
});
