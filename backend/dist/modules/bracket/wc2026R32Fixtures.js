/**
 * Dieciseisavos de final / ronda de 32 — Mundial FIFA 2026 (partidos 73–88).
 * Fuente: calendario oficial FIFA (jun–jul 2026).
 */
export const WC2026_R32_FIXTURES_RAW = [
    {
        num: 73,
        dateLocal: "2026-06-28",
        timeLocal: "15:00",
        city: "Los Ángeles",
        homeSlot: "2º Grupo A",
        awaySlot: "2º Grupo B"
    },
    {
        num: 74,
        dateLocal: "2026-06-29",
        timeLocal: "12:30",
        city: "Boston",
        homeSlot: "1º Grupo E",
        awaySlot: "3º Grupo A/B/C/D/F",
        thirdAwayGroups: ["A", "B", "C", "D", "F"]
    },
    {
        num: 75,
        dateLocal: "2026-06-29",
        timeLocal: "18:00",
        city: "Monterrey",
        homeSlot: "1º Grupo F",
        awaySlot: "2º Grupo C"
    },
    {
        num: 76,
        dateLocal: "2026-06-29",
        timeLocal: "21:30",
        city: "Houston",
        homeSlot: "1º Grupo C",
        awaySlot: "2º Grupo F"
    },
    {
        num: 77,
        dateLocal: "2026-06-30",
        timeLocal: "13:00",
        city: "Nueva York / Nueva Jersey",
        homeSlot: "1º Grupo I",
        awaySlot: "3º Grupo C/D/F/G/H",
        thirdAwayGroups: ["C", "D", "F", "G", "H"]
    },
    {
        num: 78,
        dateLocal: "2026-06-30",
        timeLocal: "17:00",
        city: "Dallas",
        homeSlot: "2º Grupo E",
        awaySlot: "2º Grupo I"
    },
    {
        num: 79,
        dateLocal: "2026-06-30",
        timeLocal: "20:00",
        city: "Ciudad de México",
        homeSlot: "1º Grupo A",
        awaySlot: "3º Grupo C/E/F/H/I",
        thirdAwayGroups: ["C", "E", "F", "H", "I"]
    },
    {
        num: 80,
        dateLocal: "2026-07-01",
        timeLocal: "13:00",
        city: "Atlanta",
        homeSlot: "1º Grupo L",
        awaySlot: "3º Grupo E/H/I/J/K",
        thirdAwayGroups: ["E", "H", "I", "J", "K"]
    },
    {
        num: 81,
        dateLocal: "2026-07-01",
        timeLocal: "16:00",
        city: "Bahía de San Francisco",
        homeSlot: "1º Grupo D",
        awaySlot: "3º Grupo B/E/F/I/J",
        thirdAwayGroups: ["B", "E", "F", "I", "J"]
    },
    {
        num: 82,
        dateLocal: "2026-07-01",
        timeLocal: "19:00",
        city: "Seattle",
        homeSlot: "1º Grupo G",
        awaySlot: "3º Grupo A/E/H/I/J",
        thirdAwayGroups: ["A", "E", "H", "I", "J"]
    },
    {
        num: 83,
        dateLocal: "2026-07-02",
        timeLocal: "13:00",
        city: "Toronto",
        homeSlot: "2º Grupo K",
        awaySlot: "2º Grupo L"
    },
    {
        num: 84,
        dateLocal: "2026-07-02",
        timeLocal: "17:00",
        city: "Los Ángeles",
        homeSlot: "1º Grupo H",
        awaySlot: "2º Grupo J"
    },
    {
        num: 85,
        dateLocal: "2026-07-02",
        timeLocal: "20:00",
        city: "Vancouver",
        homeSlot: "1º Grupo B",
        awaySlot: "3º Grupo E/F/G/I/J",
        thirdAwayGroups: ["E", "F", "G", "I", "J"]
    },
    {
        num: 86,
        dateLocal: "2026-07-03",
        timeLocal: "14:00",
        city: "Miami",
        homeSlot: "1º Grupo J",
        awaySlot: "2º Grupo H"
    },
    {
        num: 87,
        dateLocal: "2026-07-03",
        timeLocal: "17:30",
        city: "Kansas City",
        homeSlot: "1º Grupo K",
        awaySlot: "3º Grupo D/E/I/J/L",
        thirdAwayGroups: ["D", "E", "I", "J", "L"]
    },
    {
        num: 88,
        dateLocal: "2026-07-03",
        timeLocal: "20:00",
        city: "Dallas",
        homeSlot: "2º Grupo D",
        awaySlot: "2º Grupo G"
    }
];
export const WC2026_R32_TO_R16 = [
    { r32Nums: [73, 75], r16Num: 90, side: "left" },
    { r32Nums: [74, 77], r16Num: 89, side: "left" },
    { r32Nums: [76, 78], r16Num: 91, side: "left" },
    { r32Nums: [79, 80], r16Num: 92, side: "left" },
    { r32Nums: [83, 84], r16Num: 93, side: "right" },
    { r32Nums: [81, 82], r16Num: 94, side: "right" },
    { r32Nums: [86, 88], r16Num: 95, side: "right" },
    { r32Nums: [85, 87], r16Num: 96, side: "right" }
];
export const WC2026_R16_TO_R8 = [
    { r16Num: 89, r8Num: 97 },
    { r16Num: 90, r8Num: 97 },
    { r16Num: 91, r8Num: 99 },
    { r16Num: 92, r8Num: 99 },
    { r16Num: 93, r8Num: 98 },
    { r16Num: 94, r8Num: 98 },
    { r16Num: 95, r8Num: 100 },
    { r16Num: 96, r8Num: 100 }
];
export function r16LinkForR32(num) {
    return WC2026_R32_TO_R16.find((l) => l.r32Nums[0] === num || l.r32Nums[1] === num);
}
export function r8NumForR16(r16Num) {
    return WC2026_R16_TO_R8.find((l) => l.r16Num === r16Num)?.r8Num;
}
/** Octavos (89–96) → cuartos (97–100). */
export function r4NumForR16(r16Num) {
    const map = {
        89: 97,
        90: 97,
        91: 99,
        92: 99,
        93: 98,
        94: 98,
        95: 100,
        96: 100
    };
    return map[r16Num];
}
