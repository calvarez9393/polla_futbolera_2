import { useCallback, useEffect, useState } from "react";
import type { FormEvent } from "react";
import { useLocation } from "react-router-dom";
import { api } from "../lib/api";
import { getToken, getUser } from "../lib/auth";

interface BonusesResponse {
  picks: { topScorer: string | null; topAssister: string | null };
  extrasWindow?: { openDate: string | null; closeDate: string | null; open: boolean };
}

/**
 * Modal obligatorio: si el plazo está abierto y al participante le falta el goleador
 * o el máximo asistidor, no puede usar la app hasta llenar ambos.
 */
export function ExtrasReminderModal() {
  const location = useLocation();
  const [open, setOpen] = useState(false);
  const [topScorer, setTopScorer] = useState("");
  const [topAssister, setTopAssister] = useState("");
  const [closeDate, setCloseDate] = useState<string | null>(null);
  const [error, setError] = useState("");
  const [saving, setSaving] = useState(false);
  const [done, setDone] = useState(false);

  const check = useCallback(async () => {
    if (done) return;
    if (!getToken() || getUser()?.role !== "USER") return;
    try {
      const res = await api<BonusesResponse>("/predictions/me/bonuses");
      const windowOpen = res.extrasWindow ? res.extrasWindow.open : true;
      const scorer = res.picks.topScorer ?? "";
      const assister = res.picks.topAssister ?? "";
      if (windowOpen && (!scorer.trim() || !assister.trim())) {
        setTopScorer(scorer);
        setTopAssister(assister);
        setCloseDate(res.extrasWindow?.closeDate ?? null);
        setOpen(true);
      } else {
        setOpen(false);
        setDone(true);
      }
    } catch {
      // Si falla la carga no bloqueamos al usuario.
    }
  }, [done]);

  useEffect(() => {
    check().catch(() => undefined);
  }, [check, location.pathname]);

  useEffect(() => {
    if (!open) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev;
    };
  }, [open]);

  if (!open) return null;

  const canSubmit = topScorer.trim().length > 0 && topAssister.trim().length > 0 && !saving;

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    if (topScorer.trim().length === 0 || topAssister.trim().length === 0 || saving) return;
    setSaving(true);
    setError("");
    try {
      await api("/predictions/me/bonuses", {
        method: "PUT",
        body: JSON.stringify({ topScorer: topScorer.trim(), topAssister: topAssister.trim() })
      });
      setDone(true);
      setOpen(false);
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="modal-overlay" role="presentation">
      <div className="modal-dialog" role="dialog" aria-modal="true">
        <header className="modal-header">
          <h2 className="modal-title">⚽ ¡Último día para tus premios!</h2>
        </header>
        <div className="modal-body">
          <p style={{ marginBottom: "0.75rem", fontWeight: 600 }}>
            Hoy se acaba la primera ronda del Mundial. Hoy es el último día para que pongas quién
            crees que va a quedar de <strong>goleador</strong> y <strong>máximo asistidor</strong> del
            torneo.
          </p>
          <p className="admin-block-hint" style={{ marginBottom: "1rem" }}>
            No podrás continuar hasta llenar ambos
            {closeDate ? ` (el plazo cierra el ${closeDate})` : ""}. Podrás cambiarlos luego mientras
            el plazo siga abierto.
          </p>
          <form onSubmit={onSubmit}>
            <div className="field">
              <label>Goleador del Mundial (25 pts)</label>
              <input
                className="input"
                value={topScorer}
                onChange={(e) => setTopScorer(e.target.value)}
                placeholder="Nombre del jugador"
                autoFocus
              />
            </div>
            <div className="field">
              <label>Máximo asistidor (20 pts)</label>
              <input
                className="input"
                value={topAssister}
                onChange={(e) => setTopAssister(e.target.value)}
                placeholder="Nombre del jugador"
              />
            </div>
            {error && (
              <div className="alert alert-error" style={{ marginTop: "0.75rem" }}>
                {error}
              </div>
            )}
            <button
              type="submit"
              className="btn btn-primary btn-block"
              style={{ marginTop: "1rem" }}
              disabled={!canSubmit}
            >
              {saving ? "Guardando…" : "Guardar y continuar"}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
