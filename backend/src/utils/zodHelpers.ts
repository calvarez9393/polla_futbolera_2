import { z } from "zod";

function emptyToNull(value: unknown): unknown {
  if (value === null || value === undefined || value === "") return null;
  if (value === 0 || value === "0") return null;
  return value;
}

/** ID de equipo opcional: null, vacío o 0 se tratan como ausencia. */
export const optionalTeamId = z.preprocess(
  emptyToNull,
  z.coerce.number().int().positive().nullable()
).optional();
