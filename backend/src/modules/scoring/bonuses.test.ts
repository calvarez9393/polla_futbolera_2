import { describe, expect, it } from "vitest";
import { allocatePrizePointsByMatch, sameTeamId } from "./bonuses.js";

const A = 10;
const B = 11;
const C = 12;
const D = 13;

describe("allocatePrizePointsByMatch", () => {
  it("asigna los puntos de cada acierto al partido que lo consagró", () => {
    const alloc = allocatePrizePointsByMatch([A, B], { [A]: 101, [B]: 102 }, 20, 40);
    expect(alloc.byMatch.get(101)).toBe(20);
    expect(alloc.byMatch.get(102)).toBe(20);
    expect(alloc.unsourced).toBe(0);
  });

  it("respeta el tope total de la categoría en orden de partido", () => {
    const alloc = allocatePrizePointsByMatch([A, B, C, D], { [A]: 97, [B]: 98, [C]: 99, [D]: 100 }, 10, 25);
    expect(alloc.byMatch.get(97)).toBe(10);
    expect(alloc.byMatch.get(98)).toBe(10);
    expect(alloc.byMatch.get(99)).toBe(5);
    expect(alloc.byMatch.has(100)).toBe(false);
    expect(alloc.unsourced).toBe(0);
  });

  it("los aciertos sin partido de origen van al remanente (cuadro de bonus)", () => {
    const alloc = allocatePrizePointsByMatch([A, B], { [A]: 101 }, 20, 40);
    expect(alloc.byMatch.get(101)).toBe(20);
    expect(alloc.unsourced).toBe(20);
  });

  it("suma asignado + remanente igual que el puntaje con tope de la categoría", () => {
    const alloc = allocatePrizePointsByMatch([A, B, C], { [B]: 98 }, 10, 15);
    const assigned = [...alloc.byMatch.values()].reduce((acc, v) => acc + v, 0);
    // Con tope 15: primero el acierto con partido (10), luego los sin partido hasta agotar (5).
    expect(assigned + alloc.unsourced).toBe(15);
    expect(alloc.byMatch.get(98)).toBe(10);
    expect(alloc.unsourced).toBe(5);
  });

  it("sin aciertos no asigna nada", () => {
    const alloc = allocatePrizePointsByMatch([], {}, 10, 40);
    expect(alloc.byMatch.size).toBe(0);
    expect(alloc.unsourced).toBe(0);
  });
});

describe("sameTeamId", () => {
  it("acierta aunque la BD devuelva el BIGINT como string y el oficial sea número", () => {
    expect(sameTeamId("52", 52)).toBe(true);
    expect(sameTeamId(52, "52")).toBe(true);
    expect(sameTeamId(52, 52)).toBe(true);
    expect(sameTeamId("52", "52")).toBe(true);
  });

  it("no acierta con ids distintos, nulos o inválidos", () => {
    expect(sameTeamId("52", 53)).toBe(false);
    expect(sameTeamId(null, 52)).toBe(false);
    expect(sameTeamId("52", null)).toBe(false);
    expect(sameTeamId(undefined, undefined)).toBe(false);
    expect(sameTeamId("abc", NaN)).toBe(false);
    expect(sameTeamId(0, 0)).toBe(false);
  });
});
