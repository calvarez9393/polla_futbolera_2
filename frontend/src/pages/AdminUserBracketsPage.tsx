import { useCallback, useEffect, useState } from "react";
import { AdminSubnav } from "../components/AdminSubnav";
import { PageTitle } from "../components/InfoModal";
import {
  FullBracketTree,
  type FullBracketMatch,
  type SavePredictionPayload
} from "../components/FullBracketTree";
import { api } from "../lib/api";

interface CompletionUser {
  userId: number;
  email: string;
  displayName: string | null;
  totalFilled: number;
  totalMatches: number;
  complete: boolean;
}

interface SlotChange {
  num: number;
  roundLabel: string;
  fromHome: string | null;
  toHome: string | null;
  fromAway: string | null;
  toAway: string | null;
}

interface WinnerChange {
  num: number;
  roundLabel: string;
  fromWinner: string | null;
  toWinner: string | null;
}

interface ReviewItem {
  num: number;
  roundLabel: string;
  reason: string;
}

interface RepairReport {
  applied: boolean;
  totalChanges: number;
  changedSlots: SlotChange[];
  changedWinners: WinnerChange[];
  needsReview: ReviewItem[];
  rescoredMatches: number[];
}

function slotChanged(c: SlotChange, side: "home" | "away"): boolean {
  return side === "home" ? c.fromHome !== c.toHome : c.fromAway !== c.toAway;
}

function RepairPanel() {
  const [report, setReport] = useState<RepairReport | null>(null);
  const [loading, setLoading] = useState(false);
  const [msg, setMsg] = useState<{ text: string; error: boolean } | null>(null);

  async function review() {
    setLoading(true);
    setMsg(null);
    try {
      const res = await api<RepairReport>("/admin/knockout-repair");
      setReport(res);
      if (res.totalChanges === 0 && res.needsReview.length === 0) {
        setMsg({ text: "El cuadro oficial está consistente. No hay nada que corregir.", error: false });
      }
    } catch (e) {
      setMsg({ text: (e as Error).message, error: true });
    } finally {
      setLoading(false);
    }
  }

  async function apply() {
    setLoading(true);
    setMsg(null);
    try {
      const res = await api<RepairReport>("/admin/knockout-repair", { method: "POST" });
      setReport(res);
      setMsg({
        text: `Corrección aplicada: ${res.totalChanges} cambio(s) en el cuadro · ${res.rescoredMatches.length} partido(s) repuntuado(s).`,
        error: false
      });
    } catch (e) {
      setMsg({ text: (e as Error).message, error: true });
    } finally {
      setLoading(false);
    }
  }

  const hasChanges = report != null && (report.totalChanges > 0 || report.needsReview.length > 0);

  return (
    <section className="panel-card admin-repair-panel">
      <h3 className="admin-repair-title">Reparar cuadro oficial</h3>
      <p className="admin-block-hint">
        Si corregiste el resultado de un partido y las rondas siguientes quedaron con el equipo viejo,
        revisa aquí. La corrección recoloca los equipos en cada cruce y vuelve a puntuar lo afectado;
        no borra marcadores cargados.
      </p>
      <div className="admin-repair-actions">
        <button type="button" className="btn btn-ghost" onClick={review} disabled={loading}>
          {loading ? "Revisando…" : "Revisar inconsistencias"}
        </button>
        <button
          type="button"
          className="btn btn-primary"
          onClick={apply}
          disabled={loading || (report != null && !hasChanges)}
        >
          Aplicar corrección
        </button>
      </div>

      {msg && (
        <p className={`bracket-round-msg${msg.error ? " bracket-round-msg--error" : ""}`}>{msg.text}</p>
      )}

      {report != null && hasChanges && (
        <div className="admin-repair-report">
          {report.changedSlots.length > 0 && (
            <div>
              <strong>Cruces a recolocar ({report.changedSlots.length})</strong>
              <ul className="admin-repair-list">
                {report.changedSlots.map((c) => (
                  <li key={`s-${c.num}`}>
                    <span className="admin-repair-tag">{c.roundLabel}</span>{" "}
                    {slotChanged(c, "home") && (
                      <>
                        Local: <s>{c.fromHome ?? "—"}</s> → <b>{c.toHome ?? "Por definir"}</b>.{" "}
                      </>
                    )}
                    {slotChanged(c, "away") && (
                      <>
                        Visitante: <s>{c.fromAway ?? "—"}</s> → <b>{c.toAway ?? "Por definir"}</b>.
                      </>
                    )}
                  </li>
                ))}
              </ul>
            </div>
          )}
          {report.changedWinners.length > 0 && (
            <div>
              <strong>Quién avanza a corregir ({report.changedWinners.length})</strong>
              <ul className="admin-repair-list">
                {report.changedWinners.map((c) => (
                  <li key={`w-${c.num}`}>
                    <span className="admin-repair-tag">{c.roundLabel}</span> Pasa:{" "}
                    <s>{c.fromWinner ?? "—"}</s> → <b>{c.toWinner ?? "Por definir"}</b>.
                  </li>
                ))}
              </ul>
            </div>
          )}
          {report.needsReview.length > 0 && (
            <div>
              <strong>Requieren tu atención ({report.needsReview.length})</strong>
              <ul className="admin-repair-list admin-repair-list--warn">
                {report.needsReview.map((c) => (
                  <li key={`r-${c.num}`}>
                    <span className="admin-repair-tag">{c.roundLabel}</span> {c.reason}
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}
    </section>
  );
}

interface SnapshotChange {
  userId: number;
  userName: string;
  num: number;
  roundLabel: string;
  fromHome: string | null;
  toHome: string | null;
  fromAway: string | null;
  toAway: string | null;
}

interface ResyncReport {
  applied: boolean;
  usersAffected: number;
  predictionsUpdated: number;
  matchesRescored: number;
  changes: SnapshotChange[];
}

const CHANGES_PREVIEW = 60;

function SnapshotResyncPanel() {
  const [report, setReport] = useState<ResyncReport | null>(null);
  const [loading, setLoading] = useState(false);
  const [msg, setMsg] = useState<{ text: string; error: boolean } | null>(null);

  async function review() {
    setLoading(true);
    setMsg(null);
    try {
      const res = await api<ResyncReport>("/admin/knockout-resync-snapshots");
      setReport(res);
      if (res.predictionsUpdated === 0) {
        setMsg({ text: "Todos los cruces guardados ya coinciden con el cuadro en vivo de cada usuario.", error: false });
      }
    } catch (e) {
      setMsg({ text: (e as Error).message, error: true });
    } finally {
      setLoading(false);
    }
  }

  async function apply() {
    setLoading(true);
    setMsg(null);
    try {
      const res = await api<ResyncReport>("/admin/knockout-resync-snapshots", { method: "POST" });
      setReport(res);
      const base = `Resincronizados ${res.predictionsUpdated} cruce(s) de ${res.usersAffected} usuario(s).`;
      const score =
        res.matchesRescored > 0
          ? ` ${res.matchesRescored} partido(s) finalizado(s) repuntuado(s).`
          : " Ninguno estaba finalizado, así que no hizo falta repuntuar.";
      setMsg({ text: base + score, error: false });
    } catch (e) {
      setMsg({ text: (e as Error).message, error: true });
    } finally {
      setLoading(false);
    }
  }

  const hasChanges = report != null && report.predictionsUpdated > 0;

  return (
    <section className="panel-card admin-repair-panel" style={{ marginTop: "1rem" }}>
      <h3 className="admin-repair-title">Resincronizar predicciones de usuarios</h3>
      <p className="admin-block-hint">
        Si un usuario llenó una ronda y luego cambió una anterior, el cruce que guardó (contra el que
        se le puntúa) quedó viejo. Esto recalcula esos cruces desde su cuadro en vivo y vuelve a
        puntuar los partidos afectados. No cambia sus marcadores predichos.
      </p>
      <div className="admin-repair-actions">
        <button type="button" className="btn btn-ghost" onClick={review} disabled={loading}>
          {loading ? "Revisando…" : "Revisar predicciones"}
        </button>
        <button
          type="button"
          className="btn btn-primary"
          onClick={apply}
          disabled={loading || (report != null && !hasChanges)}
        >
          Resincronizar y repuntuar
        </button>
      </div>

      {msg && (
        <p className={`bracket-round-msg${msg.error ? " bracket-round-msg--error" : ""}`}>{msg.text}</p>
      )}

      {report != null && hasChanges && (
        <div className="admin-repair-report">
          <strong>
            {report.predictionsUpdated} cruce(s) en {report.usersAffected} usuario(s)
            {report.applied ? "" : " a resincronizar"}
          </strong>
          <ul className="admin-repair-list">
            {report.changes.slice(0, CHANGES_PREVIEW).map((c) => (
              <li key={`${c.userId}-${c.num}`}>
                <b>{c.userName}</b> <span className="admin-repair-tag">{c.roundLabel}</span>{" "}
                <s>
                  {c.fromHome ?? "—"} vs {c.fromAway ?? "—"}
                </s>{" "}
                → <b>{c.toHome ?? "Por definir"} vs {c.toAway ?? "Por definir"}</b>
              </li>
            ))}
          </ul>
          {report.changes.length > CHANGES_PREVIEW && (
            <p className="admin-block-hint">…y {report.changes.length - CHANGES_PREVIEW} más.</p>
          )}
        </div>
      )}
    </section>
  );
}

export function AdminUserBracketsPage() {
  const [users, setUsers] = useState<CompletionUser[]>([]);
  const [selectedUserId, setSelectedUserId] = useState<number | null>(null);
  const [matches, setMatches] = useState<FullBracketMatch[]>([]);
  const [loadingUsers, setLoadingUsers] = useState(true);
  const [loadingBracket, setLoadingBracket] = useState(false);
  const [error, setError] = useState("");

  const loadUsers = useCallback(async () => {
    setLoadingUsers(true);
    try {
      const res = await api<{ users: CompletionUser[] }>("/admin/knockout-completion");
      setUsers(res.users);
      setError("");
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setLoadingUsers(false);
    }
  }, []);

  useEffect(() => {
    loadUsers().catch(() => undefined);
  }, [loadUsers]);

  const loadBracket = useCallback(async (userId: number) => {
    setLoadingBracket(true);
    try {
      const res = await api<{ matches: FullBracketMatch[] }>(`/admin/knockout-bracket/${userId}`);
      setMatches(res.matches);
      setError("");
    } catch (e) {
      setError((e as Error).message);
      setMatches([]);
    } finally {
      setLoadingBracket(false);
    }
  }, []);

  function onSelectUser(value: string) {
    const id = value ? Number(value) : null;
    setSelectedUserId(id);
    if (id != null) loadBracket(id).catch(() => undefined);
    else setMatches([]);
  }

  const savePrediction = useCallback(
    async (payload: SavePredictionPayload) => {
      if (selectedUserId == null) return;
      const res = await api<{ matches: FullBracketMatch[] }>(
        `/admin/knockout-bracket/${selectedUserId}/prediction`,
        { method: "PUT", body: JSON.stringify(payload) }
      );
      setMatches(res.matches);
    },
    [selectedUserId]
  );

  return (
    <>
      <PageTitle
        helpTitle="Cuadros por usuario"
        help={
          <p>
            Mira la ramificación completa del cuadro eliminatorio que armó cada usuario (dieciseisavos
            hasta la final), con quién hace pasar en cada llave. Abajo puedes reparar el cuadro oficial
            si una corrección dejó rondas con el equipo equivocado.
          </p>
        }
      >
        Cuadros por usuario
      </PageTitle>

      <AdminSubnav />

      {error && <div className="alert alert-error">{error}</div>}

      <RepairPanel />

      <SnapshotResyncPanel />

      <section className="panel-card" style={{ marginTop: "1rem" }}>
        <div className="admin-users-toolbar">
          <label className="admin-bracket-user-picker">
            Usuario:{" "}
            <select
              value={selectedUserId ?? ""}
              onChange={(e) => onSelectUser(e.target.value)}
              disabled={loadingUsers}
            >
              <option value="">— Selecciona —</option>
              {users.map((u) => (
                <option key={u.userId} value={u.userId}>
                  {(u.displayName || u.email) + ` (${u.totalFilled}/${u.totalMatches})`}
                </option>
              ))}
            </select>
          </label>
        </div>

        {loadingBracket && (
          <div className="panel-card empty-state">
            <strong>Cargando cuadro…</strong>
          </div>
        )}

        {!loadingBracket && selectedUserId != null && (
          <FullBracketTree matches={matches} onSave={savePrediction} />
        )}

        {!loadingBracket && selectedUserId == null && (
          <p className="admin-block-hint">Selecciona un usuario para ver su cuadro.</p>
        )}
      </section>
    </>
  );
}
