import { useCallback, useEffect, useState } from "react";
import type { FormEvent } from "react";
import { AdminSubnav } from "../components/AdminSubnav";
import { api } from "../lib/api";

interface PollaUser {
  id: number | string;
  email: string;
  displayName: string | null;
  role: string;
  amountPaid: number;
  paymentNotes: string | null;
  totalPoints: number;
  predictionsCount: number;
}

function formatMoney(n: number): string {
  return new Intl.NumberFormat("es-CO", { style: "currency", currency: "COP", maximumFractionDigits: 0 }).format(n);
}

export function AdminUsersPage() {
  const [users, setUsers] = useState<PollaUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState("");
  const [isError, setIsError] = useState(false);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [editAmount, setEditAmount] = useState(0);
  const [editNotes, setEditNotes] = useState("");
  const [editDisplayName, setEditDisplayName] = useState("");

  const [newLogin, setNewLogin] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [newDisplayName, setNewDisplayName] = useState("");
  const [newAmountPaid, setNewAmountPaid] = useState(0);

  const loadUsers = useCallback(async () => {
    setLoading(true);
    try {
      const list = await api<PollaUser[]>("/admin/users");
      setUsers(list);
    } catch {
      setUsers([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadUsers();
  }, [loadUsers]);

  async function createUser(event: FormEvent) {
    event.preventDefault();
    try {
      await api("/admin/users", {
        method: "POST",
        body: JSON.stringify({
          login: newLogin.replace(/\s/g, ""),
          password: newPassword,
          displayName: newDisplayName || undefined,
          amountPaid: newAmountPaid
        })
      });
      setNewLogin("");
      setNewPassword("");
      setNewDisplayName("");
      setNewAmountPaid(0);
      setIsError(false);
      setMessage("Usuario creado");
      loadUsers();
    } catch (e) {
      setIsError(true);
      setMessage((e as Error).message);
    }
  }

  function startEdit(user: PollaUser) {
    setEditingId(Number(user.id));
    setEditAmount(user.amountPaid);
    setEditNotes(user.paymentNotes ?? "");
    setEditDisplayName(user.displayName ?? "");
  }

  async function saveEdit() {
    if (!editingId) return;
    try {
      await api(`/admin/users/${editingId}`, {
        method: "PATCH",
        body: JSON.stringify({
          amountPaid: editAmount,
          paymentNotes: editNotes || null,
          displayName: editDisplayName || null
        })
      });
      setEditingId(null);
      setIsError(false);
      setMessage("Usuario actualizado");
      loadUsers();
    } catch (e) {
      setIsError(true);
      setMessage((e as Error).message);
    }
  }

  return (
    <>
      <AdminSubnav />
      <h1 className="page-title">Usuarios de la polla</h1>
      <p className="page-subtitle">
        Crear participantes, registrar pagos y ver puntos acumulados. Los resultados oficiales se cargan en Calendario.
      </p>

      {message && <div className={`alert ${isError ? "alert-error" : "alert-success"}`}>{message}</div>}

      <section className="panel-card">
        <h2 style={{ fontSize: "1.15rem", marginBottom: "1rem" }}>Nuevo participante</h2>
        <form className="admin-user-form" onSubmit={createUser}>
          <div className="field">
            <label>Usuario (solo números)</label>
            <input
              className="input"
              type="text"
              inputMode="numeric"
              pattern="\d{4,15}"
              required
              value={newLogin}
              onChange={(e) => setNewLogin(e.target.value.replace(/\D/g, ""))}
            />
          </div>
          <div className="field">
            <label>Contraseña</label>
            <input className="input" type="password" required minLength={6} value={newPassword} onChange={(e) => setNewPassword(e.target.value)} />
          </div>
          <div className="field">
            <label>Nombre visible</label>
            <input className="input" value={newDisplayName} onChange={(e) => setNewDisplayName(e.target.value)} />
          </div>
          <div className="field">
            <label>Abono inicial</label>
            <input className="input" type="number" min={0} value={newAmountPaid} onChange={(e) => setNewAmountPaid(Number(e.target.value))} />
          </div>
          <button type="submit" className="btn btn-primary">
            Crear usuario
          </button>
        </form>
      </section>

      <section className="panel-card">
        <h2 style={{ fontSize: "1.15rem", marginBottom: "1rem" }}>Participantes ({users.length})</h2>
        {loading ? (
          <p className="empty-state">Cargando…</p>
        ) : (
          <div className="table-scroll">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Nombre / usuario</th>
                  <th>Pagado</th>
                  <th>Puntos</th>
                  <th>Predicciones</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {users.map((u) => (
                  <tr key={u.id}>
                    <td>
                      <strong>{u.displayName || u.email}</strong>
                      {u.displayName && <div style={{ fontSize: "0.75rem", color: "var(--text-muted)" }}>{u.email}</div>}
                      {u.role === "ADMIN" && <span className="badge badge-scheduled" style={{ marginTop: 4 }}>Admin</span>}
                    </td>
                    <td>{formatMoney(u.amountPaid)}</td>
                    <td>
                      <strong style={{ fontFamily: "var(--font-serif)", fontSize: "1.1rem" }}>{u.totalPoints}</strong>
                    </td>
                    <td>{u.predictionsCount}</td>
                    <td>
                      <button type="button" className="btn btn-ghost" style={{ padding: "0.4rem 0.75rem", fontSize: "0.8rem" }} onClick={() => startEdit(u)}>
                        Editar
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      {editingId && (
        <section className="panel-card admin-edit-panel">
          <h2 style={{ fontSize: "1.1rem", marginBottom: "1rem" }}>Editar participante</h2>
          <div className="field">
            <label>Nombre visible</label>
            <input className="input" value={editDisplayName} onChange={(e) => setEditDisplayName(e.target.value)} />
          </div>
          <div className="field">
            <label>Monto pagado</label>
            <input className="input" type="number" min={0} value={editAmount} onChange={(e) => setEditAmount(Number(e.target.value))} />
          </div>
          <div className="field">
            <label>Notas de pago</label>
            <input className="input" value={editNotes} onChange={(e) => setEditNotes(e.target.value)} />
          </div>
          <div style={{ display: "flex", gap: "0.75rem" }}>
            <button type="button" className="btn btn-primary" onClick={saveEdit}>
              Guardar
            </button>
            <button type="button" className="btn btn-ghost" onClick={() => setEditingId(null)}>
              Cancelar
            </button>
          </div>
        </section>
      )}
    </>
  );
}
