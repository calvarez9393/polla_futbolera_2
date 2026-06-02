/**
 * Calendario fase de grupos — Mundial FIFA 2026 (48 equipos, 12 grupos).
 * Grupos: sorteo final 5 dic 2025; horarios locales según calendario FIFA / roadtrips.com (mar 2026).
 * Fuente: https://www.roadtrips.com/world-cup/2026-world-cup-packages/schedule/
 */
/** Equipos por grupo (orden FIFA en tabla de clasificación) */
export const WC2026_GROUPS = {
    A: ["México", "Sudáfrica", "Corea del Sur", "República Checa"],
    B: ["Canadá", "Suiza", "Catar", "Bosnia y Herzegovina"],
    C: ["Brasil", "Marruecos", "Haití", "Escocia"],
    D: ["Estados Unidos", "Paraguay", "Australia", "Turquía"],
    E: ["Alemania", "Curazao", "Costa de Marfil", "Ecuador"],
    F: ["Países Bajos", "Japón", "Suecia", "Túnez"],
    G: ["Bélgica", "Egipto", "Irán", "Nueva Zelanda"],
    H: ["España", "Cabo Verde", "Arabia Saudita", "Uruguay"],
    I: ["Francia", "Senegal", "Noruega", "Irak"],
    J: ["Argentina", "Argelia", "Austria", "Jordania"],
    K: ["Portugal", "RD Congo", "Uzbekistán", "Colombia"],
    L: ["Inglaterra", "Croacia", "Ghana", "Panamá"]
};
const CITY_TZ = {
    "Ciudad de México": "America/Mexico_City",
    Guadalajara: "America/Mexico_City",
    Toronto: "America/Toronto",
    "Los Ángeles": "America/Los_Angeles",
    Boston: "America/New_York",
    "Nueva York / Nueva Jersey": "America/New_York",
    "San Francisco": "America/Los_Angeles",
    Filadelfia: "America/New_York",
    Houston: "America/Chicago",
    Dallas: "America/Chicago",
    Monterrey: "America/Monterrey",
    Miami: "America/New_York",
    Atlanta: "America/New_York",
    Seattle: "America/Los_Angeles",
    "Kansas City": "America/Chicago",
    Vancouver: "America/Vancouver"
};
/** Desplazamiento UTC en junio 2026 (horario de verano donde aplica) */
const TZ_UTC_OFFSET_HOURS = {
    "America/Mexico_City": -6,
    "America/Monterrey": -6,
    "America/Toronto": -4,
    "America/Vancouver": -7,
    "America/Los_Angeles": -7,
    "America/New_York": -4,
    "America/Chicago": -5
};
export function fixtureKickoffUtc(f) {
    const tz = CITY_TZ[f.city];
    if (!tz)
        throw new Error(`Zona horaria no definida para ${f.city}`);
    const offset = TZ_UTC_OFFSET_HOURS[tz];
    const [y, m, d] = f.dateLocal.split("-").map(Number);
    const [hh, mm] = f.timeLocal.split(":").map(Number);
    const utcMs = Date.UTC(y, m - 1, d, hh - offset, mm, 0);
    return new Date(utcMs).toISOString();
}
/** 72 partidos — números de partido FIFA 1–72 */
export const WC2026_GROUP_FIXTURES = [
    { num: 1, matchday: 1, home: "México", away: "Sudáfrica", group: "A", dateLocal: "2026-06-11", timeLocal: "13:00", city: "Ciudad de México", venue: "Estadio Azteca" },
    { num: 2, matchday: 1, home: "Corea del Sur", away: "República Checa", group: "A", dateLocal: "2026-06-11", timeLocal: "20:00", city: "Guadalajara", venue: "Estadio Akron" },
    { num: 3, matchday: 1, home: "Canadá", away: "Bosnia y Herzegovina", group: "B", dateLocal: "2026-06-12", timeLocal: "15:00", city: "Toronto", venue: "BMO Field" },
    { num: 4, matchday: 1, home: "Estados Unidos", away: "Paraguay", group: "D", dateLocal: "2026-06-12", timeLocal: "18:00", city: "Los Ángeles", venue: "SoFi Stadium" },
    { num: 5, matchday: 1, home: "Haití", away: "Escocia", group: "C", dateLocal: "2026-06-13", timeLocal: "21:00", city: "Boston", venue: "Gillette Stadium" },
    { num: 6, matchday: 1, home: "Australia", away: "Turquía", group: "D", dateLocal: "2026-06-12", timeLocal: "21:00", city: "Vancouver", venue: "BC Place" },
    { num: 7, matchday: 1, home: "Brasil", away: "Marruecos", group: "C", dateLocal: "2026-06-13", timeLocal: "18:00", city: "Nueva York / Nueva Jersey", venue: "MetLife Stadium" },
    { num: 8, matchday: 1, home: "Catar", away: "Suiza", group: "B", dateLocal: "2026-06-13", timeLocal: "12:00", city: "San Francisco", venue: "Levi's Stadium" },
    { num: 9, matchday: 1, home: "Costa de Marfil", away: "Ecuador", group: "E", dateLocal: "2026-06-14", timeLocal: "19:00", city: "Filadelfia", venue: "Lincoln Financial Field" },
    { num: 10, matchday: 1, home: "Alemania", away: "Curazao", group: "E", dateLocal: "2026-06-14", timeLocal: "12:00", city: "Houston", venue: "NRG Stadium" },
    { num: 11, matchday: 1, home: "Países Bajos", away: "Japón", group: "F", dateLocal: "2026-06-14", timeLocal: "15:00", city: "Dallas", venue: "AT&T Stadium" },
    { num: 12, matchday: 1, home: "Suecia", away: "Túnez", group: "F", dateLocal: "2026-06-14", timeLocal: "20:00", city: "Monterrey", venue: "Estadio BBVA" },
    { num: 13, matchday: 1, home: "Arabia Saudita", away: "Uruguay", group: "H", dateLocal: "2026-06-15", timeLocal: "18:00", city: "Miami", venue: "Hard Rock Stadium" },
    { num: 14, matchday: 1, home: "España", away: "Cabo Verde", group: "H", dateLocal: "2026-06-15", timeLocal: "12:00", city: "Atlanta", venue: "Mercedes-Benz Stadium" },
    { num: 15, matchday: 1, home: "Irán", away: "Nueva Zelanda", group: "G", dateLocal: "2026-06-15", timeLocal: "18:00", city: "Los Ángeles", venue: "SoFi Stadium" },
    { num: 16, matchday: 1, home: "Bélgica", away: "Egipto", group: "G", dateLocal: "2026-06-15", timeLocal: "12:00", city: "Seattle", venue: "Lumen Field" },
    { num: 17, matchday: 1, home: "Francia", away: "Senegal", group: "I", dateLocal: "2026-06-16", timeLocal: "15:00", city: "Nueva York / Nueva Jersey", venue: "MetLife Stadium" },
    { num: 18, matchday: 1, home: "Irak", away: "Noruega", group: "I", dateLocal: "2026-06-16", timeLocal: "18:00", city: "Boston", venue: "Gillette Stadium" },
    { num: 19, matchday: 1, home: "Argentina", away: "Argelia", group: "J", dateLocal: "2026-06-16", timeLocal: "20:00", city: "Kansas City", venue: "Arrowhead Stadium" },
    { num: 20, matchday: 1, home: "Austria", away: "Jordania", group: "J", dateLocal: "2026-06-15", timeLocal: "21:00", city: "San Francisco", venue: "Levi's Stadium" },
    { num: 21, matchday: 1, home: "Ghana", away: "Panamá", group: "L", dateLocal: "2026-06-17", timeLocal: "19:00", city: "Toronto", venue: "BMO Field" },
    { num: 22, matchday: 1, home: "Inglaterra", away: "Croacia", group: "L", dateLocal: "2026-06-17", timeLocal: "15:00", city: "Dallas", venue: "AT&T Stadium" },
    { num: 23, matchday: 1, home: "Portugal", away: "RD Congo", group: "K", dateLocal: "2026-06-17", timeLocal: "12:00", city: "Houston", venue: "NRG Stadium" },
    { num: 24, matchday: 1, home: "Uzbekistán", away: "Colombia", group: "K", dateLocal: "2026-06-17", timeLocal: "20:00", city: "Ciudad de México", venue: "Estadio Azteca" },
    { num: 25, matchday: 2, home: "República Checa", away: "Sudáfrica", group: "A", dateLocal: "2026-06-18", timeLocal: "12:00", city: "Atlanta", venue: "Mercedes-Benz Stadium" },
    { num: 26, matchday: 2, home: "Suiza", away: "Bosnia y Herzegovina", group: "B", dateLocal: "2026-06-18", timeLocal: "12:00", city: "Los Ángeles", venue: "SoFi Stadium" },
    { num: 27, matchday: 2, home: "Canadá", away: "Catar", group: "B", dateLocal: "2026-06-18", timeLocal: "15:00", city: "Vancouver", venue: "BC Place" },
    { num: 28, matchday: 2, home: "México", away: "Corea del Sur", group: "A", dateLocal: "2026-06-18", timeLocal: "19:00", city: "Guadalajara", venue: "Estadio Akron" },
    { num: 29, matchday: 2, home: "Brasil", away: "Haití", group: "C", dateLocal: "2026-06-19", timeLocal: "21:00", city: "Filadelfia", venue: "Lincoln Financial Field" },
    { num: 30, matchday: 2, home: "Escocia", away: "Marruecos", group: "C", dateLocal: "2026-06-19", timeLocal: "18:00", city: "Boston", venue: "Gillette Stadium" },
    { num: 31, matchday: 2, home: "Turquía", away: "Paraguay", group: "D", dateLocal: "2026-06-19", timeLocal: "20:00", city: "San Francisco", venue: "Levi's Stadium" },
    { num: 32, matchday: 2, home: "Estados Unidos", away: "Australia", group: "D", dateLocal: "2026-06-19", timeLocal: "12:00", city: "Seattle", venue: "Lumen Field" },
    { num: 33, matchday: 2, home: "Alemania", away: "Costa de Marfil", group: "E", dateLocal: "2026-06-20", timeLocal: "16:00", city: "Toronto", venue: "BMO Field" },
    { num: 34, matchday: 2, home: "Ecuador", away: "Curazao", group: "E", dateLocal: "2026-06-20", timeLocal: "19:00", city: "Kansas City", venue: "Arrowhead Stadium" },
    { num: 35, matchday: 2, home: "Países Bajos", away: "Suecia", group: "F", dateLocal: "2026-06-20", timeLocal: "12:00", city: "Houston", venue: "NRG Stadium" },
    { num: 36, matchday: 2, home: "Túnez", away: "Japón", group: "F", dateLocal: "2026-06-19", timeLocal: "22:00", city: "Monterrey", venue: "Estadio BBVA" },
    { num: 37, matchday: 2, home: "Uruguay", away: "Cabo Verde", group: "H", dateLocal: "2026-06-21", timeLocal: "18:00", city: "Miami", venue: "Hard Rock Stadium" },
    { num: 38, matchday: 2, home: "España", away: "Arabia Saudita", group: "H", dateLocal: "2026-06-21", timeLocal: "12:00", city: "Atlanta", venue: "Mercedes-Benz Stadium" },
    { num: 39, matchday: 2, home: "Bélgica", away: "Irán", group: "G", dateLocal: "2026-06-21", timeLocal: "12:00", city: "Los Ángeles", venue: "SoFi Stadium" },
    { num: 40, matchday: 2, home: "Nueva Zelanda", away: "Egipto", group: "G", dateLocal: "2026-06-21", timeLocal: "18:00", city: "Vancouver", venue: "BC Place" },
    { num: 41, matchday: 2, home: "Noruega", away: "Senegal", group: "I", dateLocal: "2026-06-22", timeLocal: "20:00", city: "Nueva York / Nueva Jersey", venue: "MetLife Stadium" },
    { num: 42, matchday: 2, home: "Francia", away: "Irak", group: "I", dateLocal: "2026-06-22", timeLocal: "17:00", city: "Filadelfia", venue: "Lincoln Financial Field" },
    { num: 43, matchday: 2, home: "Argentina", away: "Austria", group: "J", dateLocal: "2026-06-22", timeLocal: "12:00", city: "Dallas", venue: "AT&T Stadium" },
    { num: 44, matchday: 2, home: "Jordania", away: "Argelia", group: "J", dateLocal: "2026-06-22", timeLocal: "20:00", city: "San Francisco", venue: "Levi's Stadium" },
    { num: 45, matchday: 2, home: "Inglaterra", away: "Ghana", group: "L", dateLocal: "2026-06-23", timeLocal: "16:00", city: "Boston", venue: "Gillette Stadium" },
    { num: 46, matchday: 2, home: "Panamá", away: "Croacia", group: "L", dateLocal: "2026-06-23", timeLocal: "19:00", city: "Toronto", venue: "BMO Field" },
    { num: 47, matchday: 2, home: "Portugal", away: "Uzbekistán", group: "K", dateLocal: "2026-06-23", timeLocal: "12:00", city: "Houston", venue: "NRG Stadium" },
    { num: 48, matchday: 2, home: "Colombia", away: "RD Congo", group: "K", dateLocal: "2026-06-23", timeLocal: "20:00", city: "Guadalajara", venue: "Estadio Akron" },
    { num: 49, matchday: 3, home: "Escocia", away: "Brasil", group: "C", dateLocal: "2026-06-24", timeLocal: "18:00", city: "Miami", venue: "Hard Rock Stadium" },
    { num: 50, matchday: 3, home: "Marruecos", away: "Haití", group: "C", dateLocal: "2026-06-24", timeLocal: "18:00", city: "Atlanta", venue: "Mercedes-Benz Stadium" },
    { num: 51, matchday: 3, home: "Suiza", away: "Canadá", group: "B", dateLocal: "2026-06-24", timeLocal: "12:00", city: "Vancouver", venue: "BC Place" },
    { num: 52, matchday: 3, home: "Bosnia y Herzegovina", away: "Catar", group: "B", dateLocal: "2026-06-24", timeLocal: "12:00", city: "Seattle", venue: "Lumen Field" },
    { num: 53, matchday: 3, home: "República Checa", away: "México", group: "A", dateLocal: "2026-06-24", timeLocal: "19:00", city: "Ciudad de México", venue: "Estadio Azteca" },
    { num: 54, matchday: 3, home: "Sudáfrica", away: "Corea del Sur", group: "A", dateLocal: "2026-06-24", timeLocal: "19:00", city: "Monterrey", venue: "Estadio BBVA" },
    { num: 55, matchday: 3, home: "Curazao", away: "Costa de Marfil", group: "E", dateLocal: "2026-06-25", timeLocal: "16:00", city: "Filadelfia", venue: "Lincoln Financial Field" },
    { num: 56, matchday: 3, home: "Ecuador", away: "Alemania", group: "E", dateLocal: "2026-06-25", timeLocal: "16:00", city: "Nueva York / Nueva Jersey", venue: "MetLife Stadium" },
    { num: 57, matchday: 3, home: "Japón", away: "Suecia", group: "F", dateLocal: "2026-06-25", timeLocal: "18:00", city: "Dallas", venue: "AT&T Stadium" },
    { num: 58, matchday: 3, home: "Túnez", away: "Países Bajos", group: "F", dateLocal: "2026-06-25", timeLocal: "18:00", city: "Kansas City", venue: "Arrowhead Stadium" },
    { num: 59, matchday: 3, home: "Turquía", away: "Estados Unidos", group: "D", dateLocal: "2026-06-25", timeLocal: "19:00", city: "Los Ángeles", venue: "SoFi Stadium" },
    { num: 60, matchday: 3, home: "Paraguay", away: "Australia", group: "D", dateLocal: "2026-06-25", timeLocal: "19:00", city: "San Francisco", venue: "Levi's Stadium" },
    { num: 61, matchday: 3, home: "Noruega", away: "Francia", group: "I", dateLocal: "2026-06-26", timeLocal: "15:00", city: "Boston", venue: "Gillette Stadium" },
    { num: 62, matchday: 3, home: "Senegal", away: "Irak", group: "I", dateLocal: "2026-06-26", timeLocal: "15:00", city: "Toronto", venue: "BMO Field" },
    { num: 63, matchday: 3, home: "Egipto", away: "Irán", group: "G", dateLocal: "2026-06-26", timeLocal: "20:00", city: "Seattle", venue: "Lumen Field" },
    { num: 64, matchday: 3, home: "Nueva Zelanda", away: "Bélgica", group: "G", dateLocal: "2026-06-26", timeLocal: "20:00", city: "Vancouver", venue: "BC Place" },
    { num: 65, matchday: 3, home: "Cabo Verde", away: "Arabia Saudita", group: "H", dateLocal: "2026-06-26", timeLocal: "19:00", city: "Houston", venue: "NRG Stadium" },
    { num: 66, matchday: 3, home: "Uruguay", away: "España", group: "H", dateLocal: "2026-06-26", timeLocal: "18:00", city: "Guadalajara", venue: "Estadio Akron" },
    { num: 67, matchday: 3, home: "Panamá", away: "Inglaterra", group: "L", dateLocal: "2026-06-27", timeLocal: "17:00", city: "Nueva York / Nueva Jersey", venue: "MetLife Stadium" },
    { num: 68, matchday: 3, home: "Croacia", away: "Ghana", group: "L", dateLocal: "2026-06-27", timeLocal: "17:00", city: "Filadelfia", venue: "Lincoln Financial Field" },
    { num: 69, matchday: 3, home: "Argelia", away: "Austria", group: "J", dateLocal: "2026-06-27", timeLocal: "21:00", city: "Kansas City", venue: "Arrowhead Stadium" },
    { num: 70, matchday: 3, home: "Jordania", away: "Argentina", group: "J", dateLocal: "2026-06-27", timeLocal: "21:00", city: "Dallas", venue: "AT&T Stadium" },
    { num: 71, matchday: 3, home: "Colombia", away: "Portugal", group: "K", dateLocal: "2026-06-27", timeLocal: "19:30", city: "Miami", venue: "Hard Rock Stadium" },
    { num: 72, matchday: 3, home: "RD Congo", away: "Uzbekistán", group: "K", dateLocal: "2026-06-27", timeLocal: "19:30", city: "Atlanta", venue: "Mercedes-Benz Stadium" }
];
