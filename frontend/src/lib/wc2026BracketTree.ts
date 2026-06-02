/** Estructura del cuadro FIFA 2026 — dieciseisavos → octavos → cuartos. */

export interface BracketTreePair {
  side: "left" | "right";
  r32Nums: [number, number];
  r16Num: number;
  r8Num: number;
}

export const WC2026_BRACKET_PAIRS: BracketTreePair[] = [
  { side: "left", r32Nums: [73, 75], r16Num: 90, r8Num: 97 },
  { side: "left", r32Nums: [74, 77], r16Num: 89, r8Num: 97 },
  { side: "left", r32Nums: [76, 78], r16Num: 91, r8Num: 99 },
  { side: "left", r32Nums: [79, 80], r16Num: 92, r8Num: 99 },
  { side: "right", r32Nums: [83, 84], r16Num: 93, r8Num: 98 },
  { side: "right", r32Nums: [81, 82], r16Num: 94, r8Num: 98 },
  { side: "right", r32Nums: [86, 88], r16Num: 95, r8Num: 100 },
  { side: "right", r32Nums: [85, 87], r16Num: 96, r8Num: 100 }
];

export const WC2026_CUARTOS_BY_R8: Record<number, number> = {
  97: 97,
  98: 98,
  99: 99,
  100: 100
};
