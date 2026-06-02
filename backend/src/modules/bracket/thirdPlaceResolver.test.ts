import { describe, expect, it } from "vitest";
import { groupLetterFromName } from "./groupLetter.js";
import { assignThirdPlacesToR32Slots } from "./thirdPlaceResolver.js";
import type { FifaQualifiersResult } from "../standings/simulate.js";

describe("groupLetterFromName", () => {
  it("extrae letra desde nombre de BD", () => {
    expect(groupLetterFromName("Grupo A")).toBe("A");
    expect(groupLetterFromName("grupo l")).toBe("L");
  });
});

describe("assignThirdPlacesToR32Slots", () => {
  it("asigna 8 terceros cuando groupName es «Grupo X»", () => {
    const letters = "ABCDEFGHIJKL".split("");
    const allThirdsRanked = letters.map((letter, i) => ({
      teamId: i + 1,
      groupId: i + 1,
      groupName: `Grupo ${letter}`,
      points: 6 - Math.floor(i / 3),
      goalDiff: 3 - (i % 4),
      goalsFor: 5,
      played: 3
    }));

    const fifa: FifaQualifiersResult = {
      groups: [],
      directQualifiers: [],
      bestThirds: allThirdsRanked.slice(0, 8),
      allThirdsRanked
    };

    const map = assignThirdPlacesToR32Slots(fifa);
    expect(map.size).toBe(8);
  });
});
