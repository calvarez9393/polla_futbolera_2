import { describe, expect, it } from "vitest";
import { sameKnockoutMatchup } from "./knockoutMatchup.js";

const TBD = 1;

describe("sameKnockoutMatchup", () => {
  it("coincide sin importar local/visitante", () => {
    expect(sameKnockoutMatchup(10, 11, 11, 10, TBD)).toBe(true);
  });

  it("no coincide si falta un equipo", () => {
    expect(sameKnockoutMatchup(10, TBD, 10, 11, TBD)).toBe(false);
  });

  it("no coincide con parejas distintas", () => {
    expect(sameKnockoutMatchup(10, 11, 12, 13, TBD)).toBe(false);
  });
});
