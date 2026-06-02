import { r16LinkForR32, WC2026_R32_FIXTURES_RAW } from "./wc2026R32Fixtures.js";

export type R16SlotKind = "first" | "second" | "third_combo";

export interface R16SlotRef {
  kind: R16SlotKind;
  group: string;
  /** Partido R32 (73–88) cuando kind === third_combo. */
  matchNum?: number;
}

export interface R16FixtureDef {
  matchNumber: number;
  externalNum: number;
  label: string;
  homeSlot: R16SlotRef;
  awaySlot: R16SlotRef;
  homeSlotLabel: string;
  awaySlotLabel: string;
  dateLocal: string;
  city: string;
  octavosMatchNum: number;
  bracketSide: "left" | "right";
}

function parseRankSlot(label: string): R16SlotRef | null {
  const rankMatch = label.match(/^([12])º\s+Grupo\s+([A-L])$/i);
  if (!rankMatch) return null;
  return {
    kind: rankMatch[1] === "1" ? "first" : "second",
    group: rankMatch[2].toUpperCase()
  };
}

export const WC2026_R16_FIXTURES: R16FixtureDef[] = WC2026_R32_FIXTURES_RAW.map((fx, index) => {
  const home = parseRankSlot(fx.homeSlot);
  if (!home) throw new Error(`Ranura local no reconocida: ${fx.homeSlot}`);

  let away: R16SlotRef;
  if (fx.thirdAwayGroups?.length) {
    away = { kind: "third_combo", group: "", matchNum: fx.num };
  } else {
    const parsed = parseRankSlot(fx.awaySlot);
    if (!parsed) throw new Error(`Ranura visitante no reconocida: ${fx.awaySlot}`);
    away = parsed;
  }

  const link = r16LinkForR32(fx.num)!;

  return {
    matchNumber: index + 1,
    externalNum: fx.num,
    label: `Dieciseisavos · Partido ${fx.num}`,
    homeSlot: home,
    awaySlot: away,
    homeSlotLabel: fx.homeSlot,
    awaySlotLabel: fx.awaySlot,
    dateLocal: fx.dateLocal,
    city: fx.city,
    octavosMatchNum: link.r16Num,
    bracketSide: link.side
  };
});

export function slotRefToLabel(slot: R16SlotRef): string {
  if (slot.kind === "third_combo") {
    const fx = WC2026_R32_FIXTURES_RAW.find((f) => f.num === slot.matchNum);
    return fx?.awaySlot ?? "3º clasificado";
  }
  const rank = slot.kind === "first" ? "1º" : "2º";
  return `${rank} Grupo ${slot.group}`;
}

export function isValidGroupLetter(group: string): boolean {
  return "ABCDEFGHIJKL".includes(group.toUpperCase());
}
