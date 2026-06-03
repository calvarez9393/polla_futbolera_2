import { useCallback, useEffect, useMemo, useState } from "react";
import type { FormEvent } from "react";
import { AdminSubnav } from "../components/AdminSubnav";
import { InfoModal, PageTitle } from "../components/InfoModal";
import { Modal } from "../components/Modal";
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

function digitsOnly(value: string): string {
  return value.replace(/\D/g, "");
}

function matchesSearch(user: PollaUser, query: string): boolean {
  const q = query.trim().toLowerCase();
  if (!q) return true;
  const qDigits = digitsOnly(q);
  const login = user.email.toLowerCase();
  const name = (user.displayName ?? "").toLowerCase();
  const notes = (user.paymentNotes ?? "").toLowerCase();
  if (login.includes(q) || name.includes(q) || notes.includes(q)) return true;
  if (qDigits && (login.includes(qDigits) || digitsOnly(user.email).includes(qDigits))) return true;
  return false;
}

const emptyCreateForm = () => ({
  login: "",
  password: "",
  displayName: "",
  amountPaid: 0
});

export function AdminUsersPage() {
  const [users, setUsers] = useState<PollaUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState("");
  const [isError, setIsError] = useState(false);
  const [search, setSearch] = useState("");

  const [createOpen, setCreateOpen] = useState(false);
  const [createForm, setCreateForm] = useState(emptyCreateForm);
  const [creating, setCreating] = useState(false);

  const [editUser, setEditUser] = useState<PollaUser | null>(null);
  const [editDisplayName, setEditDisplayName] = useState("");
  const [editAmount, setEditAmount] = useState(0);
  const [editNotes, setEditNotes] = useState("");
  const [editPassword, setEditPassword] = useState("");
  const [saving, setSaving] = useState(false);

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

  const filteredUsers = useMemo(() => users.filter((u) => matchesSearch(u, search)), [users, search]);

  function openCreate() {
    setCreateForm(emptyCreateForm());
    setCreateOpen(true);
  }

  function openEdit(user: PollaUser) {
    setEditUser(user);
    setEditDisplayName(user.displayName ?? "");
    setEditAmount(user.amountPaid);
    setEditNotes(user.paymentNotes ?? "");
    setEditPassword("");
  }

  function closeCreate() {
    setCreateOpen(false);
    setCreateForm(emptyCreateForm());
  }

  function closeEdit() {
    setEditUser(null);
    setEditPassword("");
  }

  async function createUser(event: FormEvent) {
    event.preventDefault();
    const login = digitsOnly(createForm.login);
    if (login.length < 4) {
      setIsError(true);
      setMessage("El código de usuario debe tener al menos 4 dígitos");
      return;
    }
    setCreating(true);
    try {
      await api("/admin/users", {
        method: "POST",
        body: JSON.stringify({
          login,
          password: createForm.password,
          displayName: createForm.displayName || undefined,
          amountPaid: createForm.amountPaid
        })
      });
      closeCreate();
      setIsError(false);
      setMessage("Usuario creado");
      loadUsers();
    } catch (e) {
      setIsError(true);
      setMessage((e as Error).message);
    } finally {
      setCreating(false);
    }
  }

  async function saveEdit(event: FormEvent) {
    event.preventDefault();
    if (!editUser) return;
    setSaving(true);
    try {
      await api(`/admin/users/${editUser.id}`, {
        method: "PATCH",
        body: JSON.stringify({
          amountPaid: editAmount,
          paymentNotes: editNotes || null,
          displayName: editDisplayName || null,
          ...(editPassword.length >= 6 ? { password: editPassword } : {})
        })
      });
      closeEdit();
      setIsError(false);
      setMessage("Usuario actualizado");
      loadUsers();
    } catch (e) {
      setIsError(true);
      setMessage((e as Error).message);
    } finally {
      setSaving(false);
    }
  }

  return (
    <>
      <AdminSubnav />
      <PageTitle
        helpTitle="Usuarios de la polla"
        help={<p>Cada participante tiene un código numérico para iniciar sesión. Registra pagos y consulta puntos.</p>}
      >
        Usuarios de la polla
      </PageTitle>

      {message && <div className={`alert ${isError ? "alert-error" : "alert-success"}`}>{message}</div>}

      <section className="panel-card">
        <div className="admin-users-toolbar">
          <div className="field admin-users-search">
            <label htmlFor="user-search">Buscar usuario</label>
            <input
              id="user-search"
              className="input"
              type="search"
              placeholder="Código, nombre o notas de pago…"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              autoComplete="off"
            />
          </div>
          <button type="button" className="btn btn-primary" onClick={openCreate}>
            Nuevo participante
          </button>
        </div>

        <h2 style={{ fontSize: "1.15rem", marginBottom: "1rem" }}>
          Participantes ({filteredUsers.length}
          {search.trim() ? ` de ${users.length}` : ""})
        </h2>

        {loading ? (
          <p className="empty-state">Cargando…</p>
        ) : filteredUsers.length === 0 ? (
          <p className="empty-state">{search.trim() ? "Ningún usuario coincide con la búsqueda." : "No hay participantes."}</p>
        ) : (
          <div className="table-scroll">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Código</th>
                  <th>Nombre</th>
                  <th>Pagado</th>
                  <th>Puntos</th>
                  <th>Predicciones</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map((u) => (
                  <tr key={u.id}>
                    <td>
                      <code className="user-code">{u.email}</code>
                      {u.role === "ADMIN" && (
                        <span className="badge badge-scheduled" style={{ marginTop: 4, display: "inline-block" }}>
                          Admin
                        </span>
                      )}
                    </td>
                    <td>{u.displayName || <span className="text-muted">—</span>}</td>
                    <td>{formatMoney(u.amountPaid)}</td>
                    <td>
                      <strong style={{ fontFamily: "var(--font-serif)", fontSize: "1.1rem" }}>{u.totalPoints}</strong>
                    </td>
                    <td>{u.predictionsCount}</td>
                    <td>
                      <button
                        type="button"
                        className="btn btn-ghost"
                        style={{ padding: "0.4rem 0.75rem", fontSize: "0.8rem" }}
                        onClick={() => openEdit(u)}
                      >
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

      <Modal
        title="Nuevo participante"
        open={createOpen}
        onClose={closeCreate}
        footer={
          <>
            <button type="button" className="btn btn-ghost" onClick={closeCreate} disabled={creating}>
              Cancelar
            </button>
            <button type="submit" form="create-user-form" className="btn btn-primary" disabled={creating}>
              {creating ? "Creando…" : "Crear usuario"}
            </button>
          </>
        }
      >
        <form id="create-user-form" className="modal-form" onSubmit={createUser}>
          <div className="field">
            <label htmlFor="new-login" className="label-with-help">
              Código de usuario (solo números)
              <InfoModal title="Código de usuario">
                <p>Mínimo 4 dígitos. Es el usuario para iniciar sesión.</p>
              </InfoModal>
            </label>
            <input
              id="new-login"
              className="input"
              type="text"
              inputMode="numeric"
              pattern="\d{4,15}"
              required
              minLength={4}
              maxLength={15}
              placeholder="Ej. 12345678"
              value={createForm.login}
              onChange={(e) => setCreateForm((f) => ({ ...f, login: digitsOnly(e.target.value) }))}
            />
          </div>
          <div className="field">
            <label htmlFor="new-password">Contraseña</label>
            <input
              id="new-password"
              className="input"
              type="password"
              required
              minLength={6}
              value={createForm.password}
              onChange={(e) => setCreateForm((f) => ({ ...f, password: e.target.value }))}
            />
          </div>
          <div className="field">
            <label htmlFor="new-display">Nombre visible</label>
            <input
              id="new-display"
              className="input"
              value={createForm.displayName}
              onChange={(e) => setCreateForm((f) => ({ ...f, displayName: e.target.value }))}
            />
          </div>
          <div className="field">
            <label htmlFor="new-amount">Abono inicial</label>
            <input
              id="new-amount"
              className="input"
              type="number"
              min={0}
              value={createForm.amountPaid}
              onChange={(e) => setCreateForm((f) => ({ ...f, amountPaid: Number(e.target.value) }))}
            />
          </div>
        </form>
      </Modal>

      <Modal
        title="Editar participante"
        open={editUser !== null}
        onClose={closeEdit}
        footer={
          <>
            <button type="button" className="btn btn-ghost" onClick={closeEdit} disabled={saving}>
              Cancelar
            </button>
            <button type="submit" form="edit-user-form" className="btn btn-primary" disabled={saving}>
              {saving ? "Guardando…" : "Guardar cambios"}
            </button>
          </>
        }
      >
        {editUser && (
          <form id="edit-user-form" className="modal-form" onSubmit={saveEdit}>
            <div className="field">
              <label htmlFor="edit-login">Código de usuario</label>
              <input
                id="edit-login"
                className="input input-readonly"
                type="text"
                value={editUser.email}
                readOnly
                disabled
              />
            </div>
            <div className="field">
              <label htmlFor="edit-display">Nombre visible</label>
              <input
                id="edit-display"
                className="input"
                value={editDisplayName}
                onChange={(e) => setEditDisplayName(e.target.value)}
              />
            </div>
            <div className="field">
              <label htmlFor="edit-amount">Monto pagado</label>
              <input
                id="edit-amount"
                className="input"
                type="number"
                min={0}
                value={editAmount}
                onChange={(e) => setEditAmount(Number(e.target.value))}
              />
            </div>
            <div className="field">
              <label htmlFor="edit-notes">Notas de pago</label>
              <input id="edit-notes" className="input" value={editNotes} onChange={(e) => setEditNotes(e.target.value)} />
            </div>
            <div className="field">
              <label htmlFor="edit-password">Nueva contraseña (opcional)</label>
              <input
                id="edit-password"
                className="input"
                type="password"
                minLength={6}
                placeholder="Dejar vacío para no cambiar"
                value={editPassword}
                onChange={(e) => setEditPassword(e.target.value)}
              />
            </div>
          </form>
        )}
      </Modal>
    </>
  );
}
