import axios from "axios";
import { HttpError } from "../../utils/httpError.js";

export function toFootballApiError(error: unknown): HttpError {
  if (axios.isAxiosError(error)) {
    const status = error.response?.status;
    const providerMessage =
      typeof error.response?.data === "object" &&
      error.response?.data !== null &&
      "message" in error.response.data
        ? String((error.response.data as { message?: string }).message)
        : undefined;

    if (status === 403) {
      return new HttpError(
        "API-Football rechazó la petición (403). Revisa que API_FOOTBALL_KEY sea válida en tu .env y que el plan incluya esta liga/temporada.",
        502,
        "API_FOOTBALL_FORBIDDEN"
      );
    }

    if (status === 429) {
      return new HttpError(
        "Límite de uso de API-Football alcanzado (429). Espera unos minutos o reduce SYNC_CRON.",
        502,
        "API_FOOTBALL_RATE_LIMIT"
      );
    }

    if (status === 401) {
      return new HttpError(
        "API-Football no autorizó la petición (401). Verifica API_FOOTBALL_KEY.",
        502,
        "API_FOOTBALL_UNAUTHORIZED"
      );
    }

    return new HttpError(
      providerMessage ?? `Error al consultar API-Football (${status ?? "sin respuesta"})`,
      502,
      "API_FOOTBALL_ERROR"
    );
  }

  if (error instanceof Error) {
    return new HttpError(error.message, 500, "SYNC_ERROR");
  }

  return new HttpError("Error desconocido durante la sincronización", 500, "SYNC_ERROR");
}
