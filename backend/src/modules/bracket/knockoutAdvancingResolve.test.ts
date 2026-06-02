import { describe, expect, it } from "vitest";
import { resolvePredictionAdvancingTeamId } from "./knockoutAdvancingResolve.js";

describe("resolvePredictionAdvancingTeamId", () => {
  const match = { stage: "KNOCKOUT", home_team_id: 10, away_team_id: 20 };

  it("toma ganador del marcador si no hay empate", () => {
    expect(resolvePredictionAdvancingTeamId(match, 2, 0, null)).toBe(10);
    expect(resolvePredictionAdvancingTeamId(match, 1, 3, null)).toBe(20);
  });

  it("en empate acepta equipo de penales aunque no coincida con ranuras BD", () => {
    expect(resolvePredictionAdvancingTeamId(match, 1, 1, null)).toBeNull();
    expect(resolvePredictionAdvancingTeamId(match, 1, 1, 99)).toBe(99);
    expect(resolvePredictionAdvancingTeamId(match, 1, 1, 20)).toBe(20);
  });
});
