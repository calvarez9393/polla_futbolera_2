import { describe, expect, it } from "vitest";
import {
  formatVenueCalendarDate,
  getKnockoutRoundWindow,
  isKnockoutRoundOpenForPredictions,
  knockoutPredictionClosedReason
} from "./knockoutPredictionWindow.js";

describe("knockoutPredictionWindow", () => {
  it("calcula ventana R16 desde fixtures", () => {
    const w = getKnockoutRoundWindow("R16");
    expect(w).toEqual({
      roundKey: "R16",
      openDate: "2026-06-28",
      closeDate: "2026-07-03"
    });
  });

  it("calcula ventana octavos", () => {
    const w = getKnockoutRoundWindow("R8");
    expect(w?.openDate).toBe("2026-07-04");
    expect(w?.closeDate).toBe("2026-07-07");
  });

  it("bloquea antes de la fecha global configurada en admin", () => {
    const beforeGlobal = new Date("2026-06-15T12:00:00-04:00");
    const config = { openDate: "2026-06-20", closeDate: null };
    expect(isKnockoutRoundOpenForPredictions("R16", beforeGlobal, config)).toBe(false);
    expect(
      knockoutPredictionClosedReason(
        { stage: "KNOCKOUT", round_key: "R16", status: "SCHEDULED" },
        new Date("2026-07-01T00:00:00Z"),
        beforeGlobal,
        config
      )
    ).toMatch(/configuración admin/);
  });

  it("permite predicciones antes del calendario FIFA si admin abrió la ventana", () => {
    const beforeR16Fixture = new Date("2026-06-15T12:00:00-04:00");
    const config = { openDate: "2026-06-01", closeDate: "2026-07-19" };
    expect(isKnockoutRoundOpenForPredictions("R16", beforeR16Fixture, config)).toBe(true);
  });

  it("bloquea predicciones antes de la ventana de ronda", () => {
    const beforeR16 = new Date("2026-06-15T12:00:00-04:00");
    expect(isKnockoutRoundOpenForPredictions("R16", beforeR16)).toBe(false);
    expect(
      knockoutPredictionClosedReason(
        { stage: "KNOCKOUT", round_key: "R16", status: "SCHEDULED" },
        new Date("2026-07-01T00:00:00Z"),
        beforeR16
      )
    ).toMatch(/se abren el/);
  });

  it("permite predicciones dentro de la ventana de ronda", () => {
    const duringR16 = new Date("2026-06-30T12:00:00-04:00");
    expect(isKnockoutRoundOpenForPredictions("R16", duringR16)).toBe(true);
  });

  it("bloquea predicciones después de la ventana de ronda", () => {
    const afterR16 = new Date("2026-07-10T12:00:00-04:00");
    expect(isKnockoutRoundOpenForPredictions("R16", afterR16)).toBe(false);
    expect(
      knockoutPredictionClosedReason(
        { stage: "KNOCKOUT", round_key: "R16", status: "SCHEDULED" },
        new Date("2026-12-01T00:00:00Z"),
        afterR16
      )
    ).toMatch(/cerraron el/);
  });

  it("usa calendario sede para el día actual", () => {
    const noonUtc = new Date("2026-06-28T16:00:00Z");
    expect(formatVenueCalendarDate(noonUtc)).toBe("2026-06-28");
  });

  it("abre eliminatorias al terminar grupos, antes de la fecha de apertura", () => {
    const beforeR16 = new Date("2026-06-15T12:00:00-04:00");
    // Sin grupos completos: cerrado por estar antes de la ventana.
    expect(isKnockoutRoundOpenForPredictions("R16", beforeR16, null, false)).toBe(false);
    // Con grupos completos: abre de inmediato aunque falte para la fecha de apertura.
    expect(isKnockoutRoundOpenForPredictions("R16", beforeR16, null, true)).toBe(true);
    expect(
      knockoutPredictionClosedReason(
        { stage: "KNOCKOUT", round_key: "R16", status: "SCHEDULED" },
        new Date("2026-07-01T00:00:00Z"),
        beforeR16,
        null,
        true
      )
    ).toBeNull();
  });

  it("respeta el cierre admin aunque los grupos hayan terminado", () => {
    const afterClose = new Date("2026-06-23T12:00:00-04:00");
    const config = { openDate: "2026-06-22", closeDate: "2026-06-22" };
    expect(isKnockoutRoundOpenForPredictions("R16", afterClose, config, true)).toBe(false);
    expect(
      knockoutPredictionClosedReason(
        { stage: "KNOCKOUT", round_key: "R16", status: "SCHEDULED" },
        new Date("2026-07-01T00:00:00Z"),
        afterClose,
        config,
        true
      )
    ).toMatch(/cerraron el/);
  });

  it("abre con cierre admin futuro cuando los grupos terminaron", () => {
    const beforeOpen = new Date("2026-06-23T12:00:00-04:00");
    const config = { openDate: "2026-06-25", closeDate: "2026-07-01" };
    // Antes de la apertura admin y sin grupos completos: cerrado.
    expect(isKnockoutRoundOpenForPredictions("R16", beforeOpen, config, false)).toBe(false);
    // Grupos completos + dentro del cierre admin: abierto pese a no llegar la apertura.
    expect(isKnockoutRoundOpenForPredictions("R16", beforeOpen, config, true)).toBe(true);
  });
});
