import { useCallback, useEffect, useState } from "react";
import { SectionTitle } from "./InfoModal";
import { api } from "../lib/api";

interface ReviewParticipant {
  userId: number;
  userLabel: string;
  topScorer: string | null;
  topScorerCorrect: boolean | null;
  topScorerExactMatch: boolean;
  topAssister: string | null;
  topAssisterCorrect: boolean | null;
  topAssisterExactMatch: boolean;
}

interface ReviewData {
  topScorer: string | null;
  topAssister: string | null;
  participants: ReviewParticipant[];
}

interface Props {
  onMessage: (message: string, isError: boolean) => void;
}

export function AdminBonusExtrasReview({ onMessage }: Props) {
  const [topScorer, setTopScorer] = useState("");
  const [topAssister, setTopAssister] = useState("");
  const [participants, setParticipants] = useState<ReviewParticipant[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await api<ReviewData>("/admin/official/bonus-extras-review");
      setTopScorer(res.topScorer ?? "");
      setTopAssister(res.topAssister ?? "");
      setParticipants(res.participants);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load().catch((err) => onMessage((err as Error).message, true));
  }, [load, onMessage]);

  function setMark(userId: number, field: "topScorerCorrect" | "topAssisterCorrect", value: boolean) {
    setParticipants((prev) =>
      prev.map((p) => (p.userId === userId ? { ...p, [field]: value } : p))
    );
  }

  function autoMarkExact() {
    setParticipants((prev) =>
      prev.map((p) => ({
        ...p,
        topScorerCorrect: p.topScorerExactMatch,
        topAssisterCorrect: p.topAssisterExactMatch
      }))
    );
  }

  async function save(thenCalculate: boolean) {
    if (thenCalculate) {
      // Sin el nombre real, los aciertos marcados NO dan puntos (el cálculo exige ambos).
      const faltantes: string[] = [];
      if (participants.some((p) => p.topScorerCorrect) && !topScorer.trim()) faltantes.push("goleador");
      if (participants.some((p) => p.topAssisterCorrect) && !topAssister.trim()) faltantes.push("asistidor");
      if (faltantes.length > 0) {
        onMessage(
          `Escribe el ${faltantes.join(" y el ")} real del Mundial antes de calcular: sin ese nombre los aciertos marcados no dan puntos.`,
          true
        );
        return;
      }
    }
    setSaving(true);
    try {
      await api("/admin/official/bonus-extras-review", {
        method: "PUT",
        body: JSON.stringify({
          topScorer: topScorer.trim() || null,
          topAssister: topAssister.trim() || null,
          marks: participants.map((p) => ({
            userId: p.userId,
            topScorerCorrect: !!p.topScorerCorrect,
            topAssisterCorrect: !!p.topAssisterCorrect
          }))
        })
      });
      if (thenCalculate) {
        const r = await api<{ usersScored?: number }>("/admin/scoring/calculate-bonuses", {
          method: "POST"
        });
        onMessage(
          `Goleador y asistidor guardados. Puntos recalculados para ${r.usersScored ?? 0} participantes.`,
          false
        );
      } else {
        onMessage("Goleador, asistidor y aciertos guardados", false);
      }
      await load();
    } catch (err) {
      onMessage((err as Error).message, true);
    } finally {
      setSaving(false);
    }
  }

  const scorerHits = participants.filter((p) => p.topScorerCorrect).length;
  const assisterHits = participants.filter((p) => p.topAssisterCorrect).length;

  return (
    <section className="panel-card" style={{ marginBottom: "1.25rem" }}>
      <SectionTitle
        as="h3"
        title="Goleador y máximo asistidor — revisión final"
        help={
          <p>
            Al final del torneo escribe el goleador y máximo asistidor reales, y marca con un{" "}
            <strong>check</strong> quién acertó. Como cada persona lo escribe distinto, el acierto se
            marca a mano: usa <strong>“Marcar coincidencias exactas”</strong> como punto de partida y
            ajusta los demás. Luego <strong>“Guardar y calcular puntos”</strong>.
          </p>
        }
      />

      <div className="field" style={{ marginTop: "0.75rem" }}>
        <label>Goleador real del Mundial</label>
        <input
          className="input"
          value={topScorer}
          onChange={(e) => setTopScorer(e.target.value)}
          placeholder="Nombre del jugador"
        />
      </div>
      <div className="field">
        <label>Máximo asistidor real</label>
        <input
          className="input"
          value={topAssister}
          onChange={(e) => setTopAssister(e.target.value)}
          placeholder="Nombre del jugador"
        />
      </div>

      <div className="admin-qualifiers-toolbar" style={{ marginTop: "0.5rem" }}>
        <button type="button" className="btn btn-ghost" onClick={autoMarkExact} disabled={loading}>
          Marcar coincidencias exactas
        </button>
      </div>

      <p className="admin-block-hint admin-qualifiers-meta">
        Aciertos marcados — goleador: <strong>{scorerHits}</strong> · asistidor:{" "}
        <strong>{assisterHits}</strong> de {participants.length} participantes.
      </p>

      {loading ? (
        <div className="panel-card empty-state" style={{ marginTop: "0.75rem" }}>
          <strong>Cargando…</strong>
        </div>
      ) : participants.length === 0 ? (
        <div className="panel-card empty-state" style={{ marginTop: "0.75rem" }}>
          <strong>Sin participantes</strong>
        </div>
      ) : (
        <div className="table-scroll" style={{ marginTop: "0.75rem" }}>
          <table className="data-table">
            <thead>
              <tr>
                <th>Participante</th>
                <th>Goleador que escribió</th>
                <th style={{ textAlign: "center" }}>Acertó</th>
                <th>Asistidor que escribió</th>
                <th style={{ textAlign: "center" }}>Acertó</th>
              </tr>
            </thead>
            <tbody>
              {participants.map((p) => (
                <tr key={p.userId}>
                  <td>{p.userLabel}</td>
                  <td>
                    {p.topScorer?.trim() ? p.topScorer : <span className="admin-block-hint">— sin llenar —</span>}
                    {p.topScorerExactMatch && (
                      <span className="badge badge-live" style={{ marginLeft: "0.4rem" }}>
                        coincide
                      </span>
                    )}
                  </td>
                  <td style={{ textAlign: "center" }}>
                    <input
                      type="checkbox"
                      checked={!!p.topScorerCorrect}
                      disabled={!p.topScorer?.trim()}
                      onChange={(e) => setMark(p.userId, "topScorerCorrect", e.target.checked)}
                      aria-label={`${p.userLabel} acertó el goleador`}
                    />
                  </td>
                  <td>
                    {p.topAssister?.trim() ? p.topAssister : <span className="admin-block-hint">— sin llenar —</span>}
                    {p.topAssisterExactMatch && (
                      <span className="badge badge-live" style={{ marginLeft: "0.4rem" }}>
                        coincide
                      </span>
                    )}
                  </td>
                  <td style={{ textAlign: "center" }}>
                    <input
                      type="checkbox"
                      checked={!!p.topAssisterCorrect}
                      disabled={!p.topAssister?.trim()}
                      onChange={(e) => setMark(p.userId, "topAssisterCorrect", e.target.checked)}
                      aria-label={`${p.userLabel} acertó el asistidor`}
                    />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <div className="admin-qualifiers-toolbar" style={{ marginTop: "1rem" }}>
        <button
          type="button"
          className="btn btn-primary"
          onClick={() => save(true)}
          disabled={saving || loading}
        >
          {saving ? "Guardando…" : "Guardar y calcular puntos"}
        </button>
        <button
          type="button"
          className="btn btn-ghost"
          onClick={() => save(false)}
          disabled={saving || loading}
        >
          Solo guardar
        </button>
      </div>
    </section>
  );
}
