import { z } from "zod";

/** Identificador de acceso numérico (documento, teléfono, etc.). Se guarda en users.email. */
export const loginIdentifierSchema = z
  .string()
  .trim()
  .min(4, "Mínimo 4 dígitos")
  .max(15, "Máximo 15 dígitos")
  .regex(/^\d+$/, "El usuario debe contener solo números");

export function normalizeLoginIdentifier(raw: string): string {
  return raw.trim().replace(/\s/g, "");
}
