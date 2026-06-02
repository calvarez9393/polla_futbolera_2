import { getToken } from "./auth";

const API_URL = import.meta.env.VITE_API_URL ?? "http://localhost:4000";

export async function api<T>(path: string, init?: RequestInit): Promise<T> {
  const token = getToken();
  const response = await fetch(`${API_URL}${path}`, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(init?.headers ?? {})
    }
  });

  if (!response.ok) {
    const maybeJson = (await response.json().catch(() => ({}))) as { message?: string; code?: string };
    const detail = maybeJson.code ? ` [${maybeJson.code}]` : "";
    throw new Error((maybeJson.message ?? `HTTP ${response.status}`) + detail);
  }

  return response.json() as Promise<T>;
}
