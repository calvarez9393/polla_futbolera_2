import { WC2026_R32_FIXTURES_RAW } from "./wc2026R32Fixtures.js";
const R8_FIXTURES = [
    {
        num: 89,
        roundKey: "R8",
        roundLabel: "Octavos de final · Partido 89",
        homeSlot: "Ganador partido 74",
        awaySlot: "Ganador partido 77",
        dateLocal: "2026-07-04",
        timeLocal: "17:00",
        city: "Filadelfia"
    },
    {
        num: 90,
        roundKey: "R8",
        roundLabel: "Octavos de final · Partido 90",
        homeSlot: "Ganador partido 73",
        awaySlot: "Ganador partido 75",
        dateLocal: "2026-07-04",
        timeLocal: "20:30",
        city: "Houston"
    },
    {
        num: 91,
        roundKey: "R8",
        roundLabel: "Octavos de final · Partido 91",
        homeSlot: "Ganador partido 76",
        awaySlot: "Ganador partido 78",
        dateLocal: "2026-07-05",
        timeLocal: "16:00",
        city: "Nueva York / Nueva Jersey"
    },
    {
        num: 92,
        roundKey: "R8",
        roundLabel: "Octavos de final · Partido 92",
        homeSlot: "Ganador partido 79",
        awaySlot: "Ganador partido 80",
        dateLocal: "2026-07-05",
        timeLocal: "19:00",
        city: "Ciudad de México"
    },
    {
        num: 93,
        roundKey: "R8",
        roundLabel: "Octavos de final · Partido 93",
        homeSlot: "Ganador partido 83",
        awaySlot: "Ganador partido 84",
        dateLocal: "2026-07-06",
        timeLocal: "16:00",
        city: "Dallas"
    },
    {
        num: 94,
        roundKey: "R8",
        roundLabel: "Octavos de final · Partido 94",
        homeSlot: "Ganador partido 81",
        awaySlot: "Ganador partido 82",
        dateLocal: "2026-07-06",
        timeLocal: "19:00",
        city: "Seattle"
    },
    {
        num: 95,
        roundKey: "R8",
        roundLabel: "Octavos de final · Partido 95",
        homeSlot: "Ganador partido 86",
        awaySlot: "Ganador partido 88",
        dateLocal: "2026-07-07",
        timeLocal: "16:00",
        city: "Atlanta"
    },
    {
        num: 96,
        roundKey: "R8",
        roundLabel: "Octavos de final · Partido 96",
        homeSlot: "Ganador partido 85",
        awaySlot: "Ganador partido 87",
        dateLocal: "2026-07-07",
        timeLocal: "19:00",
        city: "Vancouver"
    }
];
/** Cuadro eliminatorio 2026 — dieciseisavos (73–88) + octavos en adelante. */
export const WC2026_KNOCKOUT_FIXTURES = [
    ...WC2026_R32_FIXTURES_RAW.map((fx) => ({
        num: fx.num,
        roundKey: "R16",
        roundLabel: `Dieciseisavos · Partido ${fx.num}`,
        homeSlot: fx.homeSlot,
        awaySlot: fx.awaySlot,
        dateLocal: fx.dateLocal,
        timeLocal: fx.timeLocal,
        city: fx.city
    })),
    ...R8_FIXTURES,
    ...Array.from({ length: 4 }, (_, i) => ({
        num: 97 + i,
        roundKey: "R4",
        roundLabel: `Cuartos de final · Partido ${97 + i}`,
        homeSlot: `Ganador octavos ${i === 0 ? 89 : i === 1 ? 93 : i === 2 ? 91 : 95}`,
        awaySlot: `Ganador octavos ${i === 0 ? 90 : i === 1 ? 94 : i === 2 ? 92 : 96}`,
        dateLocal: i < 2 ? "2026-07-09" : "2026-07-10",
        timeLocal: "20:00",
        city: i < 2 ? "Foxborough" : "Los Ángeles"
    })),
    ...Array.from({ length: 2 }, (_, i) => ({
        num: 101 + i,
        roundKey: "SF",
        roundLabel: `Semifinal · Partido ${101 + i}`,
        homeSlot: `Ganador cuartos ${97 + i * 2}`,
        awaySlot: `Ganador cuartos ${98 + i * 2}`,
        dateLocal: "2026-07-14",
        timeLocal: "20:00",
        city: i === 0 ? "Dallas" : "Atlanta"
    })),
    {
        num: 103,
        roundKey: "TP3",
        roundLabel: "Tercer puesto",
        homeSlot: "Perdedor semifinal 1",
        awaySlot: "Perdedor semifinal 2",
        dateLocal: "2026-07-18",
        timeLocal: "17:00",
        city: "Miami"
    },
    {
        num: 104,
        roundKey: "F",
        roundLabel: "Final",
        homeSlot: "Ganador semifinal 1",
        awaySlot: "Ganador semifinal 2",
        dateLocal: "2026-07-19",
        timeLocal: "20:00",
        city: "Nueva York / Nueva Jersey"
    }
];
