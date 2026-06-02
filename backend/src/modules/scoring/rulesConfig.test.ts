import { describe, expect, it } from "vitest";
import { requiresKnockoutAdvancingTeam } from "./rulesConfig.js";

describe("requiresKnockoutAdvancingTeam", () => {
  it("no exige avance en fase de grupos", () => {
    expect(requiresKnockoutAdvancingTeam({ stage: "GROUP", round_key: "GROUP" })).toBe(false);
  });

  it("no exige avance en dieciseisavos (fase 1 eliminatoria)", () => {
    expect(requiresKnockoutAdvancingTeam({ stage: "KNOCKOUT", round_key: "R16" })).toBe(false);
  });

  it("exige avance desde octavos", () => {
    expect(requiresKnockoutAdvancingTeam({ stage: "KNOCKOUT", round_key: "R8" })).toBe(true);
    expect(requiresKnockoutAdvancingTeam({ stage: "KNOCKOUT", round_key: "F" })).toBe(true);
  });
});
