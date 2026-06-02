import { useState } from "react";
import type { FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { api } from "../lib/api";
import { saveSession } from "../lib/auth";

export function LoginPage() {
  const [login, setLogin] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError("");
    setLoading(true);
    try {
      const data = await api<{ token: string; user: { id: number; email: string; role: "USER" | "ADMIN" } }>("/auth/login", {
        method: "POST",
        body: JSON.stringify({ login: login.replace(/\s/g, ""), password })
      });
      saveSession(data.token, data.user);
      navigate("/");
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="auth-card">
        <h1>Iniciar sesión</h1>
        <p className="subtitle">Ingresa con tu número de usuario y contraseña asignados por el administrador.</p>
        {error && <div className="alert alert-error">{error}</div>}
        <form onSubmit={onSubmit}>
          <div className="field">
            <label htmlFor="login">Usuario (solo números)</label>
            <input
              id="login"
              className="input"
              type="text"
              inputMode="numeric"
              pattern="\d{4,15}"
              autoComplete="username"
              value={login}
              onChange={(e) => setLogin(e.target.value.replace(/\D/g, ""))}
              required
            />
          </div>
          <div className="field">
            <label htmlFor="password">Contraseña</label>
            <input
              id="password"
              className="input"
              type="password"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          <button type="submit" className="btn btn-primary btn-block" disabled={loading}>
            {loading ? "Entrando…" : "Entrar"}
          </button>
        </form>
    </div>
  );
}
