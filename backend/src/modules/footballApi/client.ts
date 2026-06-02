import axios from "axios";
import { env } from "../../config/env.js";

const headers: Record<string, string> = {
  "x-apisports-key": env.API_FOOTBALL_KEY
};

// Solo aplica si usas proxy tipo RapidAPI; en api-sports.io directo basta la API key.
if (env.API_FOOTBALL_BASE_URL.includes("rapidapi")) {
  headers["x-rapidapi-key"] = env.API_FOOTBALL_KEY;
  headers["x-rapidapi-host"] = env.API_FOOTBALL_HOST;
}

export const footballApi = axios.create({
  baseURL: env.API_FOOTBALL_BASE_URL,
  timeout: 10_000,
  headers
});

export async function withApiRetry<T>(fn: () => Promise<T>, retries = 2): Promise<T> {
  let lastError: unknown;
  for (let attempt = 0; attempt <= retries; attempt += 1) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      if (attempt === retries) break;
      await new Promise((resolve) => setTimeout(resolve, 500 * (attempt + 1)));
    }
  }
  throw lastError;
}
