export const KO_ROUND_ORDER = ["R16", "R8", "R4", "SF", "TP3", "F"] as const;

export const KO_ROUND_TITLES: Record<string, string> = {
  R16: "Dieciseisavos de final",
  R8: "Octavos de final",
  R4: "Cuartos de final",
  SF: "Semifinales",
  TP3: "Tercer puesto",
  F: "Final"
};

export interface KnockoutRoundGroup<T> {
  roundKey: string;
  title: string;
  matches: T[];
}

export function groupKnockoutByRound<T extends { roundKey?: string | null; startsAt: string }>(
  matches: T[]
): KnockoutRoundGroup<T>[] {
  const byKey = new Map<string, T[]>();
  for (const m of matches) {
    const key = m.roundKey ?? "OTHER";
    const list = byKey.get(key) ?? [];
    list.push(m);
    byKey.set(key, list);
  }

  const orderedKeys = [
    ...KO_ROUND_ORDER.filter((k) => byKey.has(k)),
    ...[...byKey.keys()].filter((k) => !KO_ROUND_ORDER.includes(k as (typeof KO_ROUND_ORDER)[number]))
  ];

  return orderedKeys.map((roundKey) => ({
    roundKey,
    title: KO_ROUND_TITLES[roundKey] ?? roundKey,
    matches: (byKey.get(roundKey) ?? []).sort(
      (a, b) => new Date(a.startsAt).getTime() - new Date(b.startsAt).getTime()
    )
  }));
}
