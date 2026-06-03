/** Dos parejas de equipos representan el mismo cruce (sin importar local/visitante). */
export function sameKnockoutMatchup(
  aHome: number,
  aAway: number,
  bHome: number,
  bAway: number,
  tbdId: number
): boolean {
  const pair = (h: number, a: number): number[] =>
    [Number(h), Number(a)].filter((id) => id > 0 && id !== tbdId).sort((x, y) => x - y);

  const left = pair(aHome, aAway);
  const right = pair(bHome, bAway);
  if (left.length !== 2 || right.length !== 2) return false;
  return left[0] === right[0] && left[1] === right[1];
}
