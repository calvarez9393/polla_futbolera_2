const TOKEN_KEY = "polla_token";
const USER_KEY = "polla_user";

export interface SessionUser {
  id: number;
  email: string;
  role: "USER" | "ADMIN";
}

export function saveSession(token: string, user: SessionUser): void {
  localStorage.setItem(TOKEN_KEY, token);
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function clearSession(): void {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function getUser(): SessionUser | null {
  const raw = localStorage.getItem(USER_KEY);
  return raw ? (JSON.parse(raw) as SessionUser) : null;
}

/** Reads the JWT `exp` claim without verifying the signature. */
function isTokenExpired(token: string): boolean {
  try {
    const payload = token.split(".")[1];
    const claims = JSON.parse(atob(payload.replaceAll("-", "+").replaceAll("_", "/"))) as { exp?: number };
    if (!claims.exp) return false;
    return claims.exp * 1000 <= Date.now();
  } catch {
    return true; // malformed token: treat as expired
  }
}

/** True only when a non-expired session exists. Clears an expired session as a side effect. */
export function isAuthenticated(): boolean {
  const token = getToken();
  if (!token) return false;
  if (isTokenExpired(token)) {
    clearSession();
    return false;
  }
  return true;
}
