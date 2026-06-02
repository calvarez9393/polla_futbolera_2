import { HttpError } from "../../utils/httpError.js";

interface ApiFootballPayload {
  errors?: Record<string, string> | string[] | unknown;
  results?: number;
  response?: unknown[];
}

export function extractApiFootballErrors(data: unknown): string | null {
  if (!data || typeof data !== "object") return null;
  const errors = (data as ApiFootballPayload).errors;
  if (!errors) return null;
  if (Array.isArray(errors)) {
    const messages = errors.filter(Boolean).map(String);
    return messages.length ? messages.join(" ") : null;
  }
  if (typeof errors === "object") {
    const messages = Object.values(errors as Record<string, string>).filter(Boolean);
    return messages.length ? messages.join(" ") : null;
  }
  return String(errors);
}

export function assertApiFootballOk(data: unknown, context: string): void {
  const apiError = extractApiFootballErrors(data);
  if (apiError) {
    throw new HttpError(`API-Football (${context}): ${apiError}`, 502, "API_FOOTBALL_PLAN");
  }
}
