import { useCallback, useEffect, useMemo, useState } from "react";
import type { FormEvent, MouseEvent } from "react";
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
  isActive: boolean;
  totalPoints: number;
  lateStartPoints: number;
  predictionsCount: number;
}

interface AdminMatchOption {
  id: number;
  home_team_name: string;
  away_team_name: string;
  starts_at: string;
}

// Clave que protege las acciones manuales (marcador y puntos por inicio tarde).
// Se valida en el navegador: es un seguro simple, no una barrera de seguridad real.
const ADMIN_ACTION_PASSWORD = "daniel";

function matchOptionLabel(m: AdminMatchOption): string {
  const date = new Date(m.starts_at).toLocaleDateString("es-CO", { day: "2-digit", month: "short" });
  return `${m.home_team_name} vs ${m.away_team_name} (${date})`;
}

type SortKey = "email" | "displayName" | "amountPaid" | "totalPoints" | "predictionsCount" | "isActive";
type SortDir = "asc" | "desc";

function compareUsers(a: PollaUser, b: PollaUser, key: SortKey): number {
  if (key === "email" || key === "displayName") {
    return String(a[key] ?? "").localeCompare(String(b[key] ?? ""), "es", {
      numeric: true,
      sensitivity: "base"
    });
  }
  if (key === "isActive") {
    return Number(a.isActive) - Number(b.isActive);
  }
  return Number(a[key]) - Number(b[key]);
}

function rowClass(user: PollaUser): string {
  if (!user.isActive) return "user-row--inactive";
  if (user.role !== "ADMIN" && user.amountPaid <= 0) return "user-row--unpaid";
  return "";
}

function SortableTh({
  label,
  col,
  sortKey,
  sortDir,
  onSort
}: {
  label: string;
  col: SortKey;
  sortKey: SortKey;
  sortDir: SortDir;
  onSort: (key: SortKey) => void;
}) {
  const active = sortKey === col;
  return (
    <th
      className={`sortable-th${active ? " sortable-th--active" : ""}`}
      aria-sort={active ? (sortDir === "asc" ? "ascending" : "descending") : "none"}
      onClick={() => onSort(col)}
    >
      {label}
      <span className="sort-arrow" aria-hidden="true">
        {active ? (sortDir === "asc" ? "▲" : "▼") : "↕"}
      </span>
    </th>
  );
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
  const [showInactive, setShowInactive] = useState(false);
  const [sortKey, setSortKey] = useState<SortKey>("email");
  const [sortDir, setSortDir] = useState<SortDir>("asc");

  const [createOpen, setCreateOpen] = useState(false);
  const [createForm, setCreateForm] = useState(emptyCreateForm);
  const [creating, setCreating] = useState(false);

  const [editUser, setEditUser] = useState<PollaUser | null>(null);
  const [editDisplayName, setEditDisplayName] = useState("");
  const [editAmount, setEditAmount] = useState(0);
  const [editNotes, setEditNotes] = useState("");
  const [editPassword, setEditPassword] = useState("");
  const [saving, setSaving] = useState(false);

  // Menú de acciones por fila. "Ver más" (protegido con contraseña) revela las
  // acciones avanzadas (marcador e inicio tarde) para el usuario indicado.
  const [menu, setMenu] = useState<{ user: PollaUser; top: number; right: number } | null>(null);
  const [revealExtrasId, setRevealExtrasId] = useState<PollaUser["id"] | null>(null);

  // Marcador (pronóstico de un partido, solo escritura)
  const [markerUser, setMarkerUser] = useState<PollaUser | null>(null);
  const [matches, setMatches] = useState<AdminMatchOption[]>([]);
  const [matchesLoading, setMatchesLoading] = useState(false);
  const [markerMatchId, setMarkerMatchId] = useState("");
  const [markerHome, setMarkerHome] = useState(0);
  const [markerAway, setMarkerAway] = useState(0);
  const [markerSaving, setMarkerSaving] = useState(false);

  // Puntos por inicio tarde (puntos manuales)
  const [lateUser, setLateUser] = useState<PollaUser | null>(null);
  const [lateValue, setLateValue] = useState(0);
  const [lateSaving, setLateSaving] = useState(false);

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

  const inactiveCount = useMemo(() => users.filter((u) => !u.isActive).length, [users]);

  const filteredUsers = useMemo(() => {
    const filtered = users.filter((u) => (showInactive || u.isActive) && matchesSearch(u, search));
    return filtered.sort((a, b) => {
      const cmp = compareUsers(a, b, sortKey);
      return sortDir === "asc" ? cmp : -cmp;
    });
  }, [users, search, showInactive, sortKey, sortDir]);

  function toggleSort(key: SortKey) {
    if (sortKey === key) {
      setSortDir((d) => (d === "asc" ? "desc" : "asc"));
    } else {
      setSortKey(key);
      setSortDir("asc");
    }
  }

  async function toggleActive(user: PollaUser) {
    if (
      user.isActive &&
      !window.confirm(
        `¿Desactivar a ${user.displayName || user.email}? No podrá iniciar sesión ni aparecer en el ranking.`
      )
    ) {
      return;
    }
    try {
      await api(`/admin/users/${user.id}`, {
        method: "PATCH",
        body: JSON.stringify({ isActive: !user.isActive })
      });
      setIsError(false);
      setMessage(user.isActive ? "Usuario desactivado" : "Usuario activado");
      loadUsers();
    } catch (e) {
      setIsError(true);
      setMessage((e as Error).message);
    }
  }

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

  const loadMatches = useCallback(async () => {
    setMatchesLoading(true);
    try {
      const rows = await api<AdminMatchOption[]>("/matches");
      setMatches(rows);
    } catch {
      setMatches([]);
    } finally {
      setMatchesLoading(false);
    }
  }, []);

  function openMenu(event: MouseEvent<HTMLButtonElement>, user: PollaUser) {
    const rect = event.currentTarget.getBoundingClientRect();
    setRevealExtrasId(null);
    setMenu({ user, top: rect.bottom + 6, right: window.innerWidth - rect.right });
  }

  function closeMenu() {
    setMenu(null);
  }

  function revealExtras(userId: PollaUser["id"]) {
    const pwd = window.prompt("Contraseña para acciones avanzadas (marcador e inicio tarde)");
    if (pwd === null) return;
    if (pwd === ADMIN_ACTION_PASSWORD) {
      setRevealExtrasId(userId);
    } else {
      setIsError(true);
      setMessage("Contraseña incorrecta");
    }
  }

  function openMarker(user: PollaUser) {
    setMarkerUser(user);
    setMarkerMatchId("");
    setMarkerHome(0);
    setMarkerAway(0);
    if (matches.length === 0) void loadMatches();
  }

  function closeMarker() {
    setMarkerUser(null);
  }

  async function saveMarker(event: FormEvent) {
    event.preventDefault();
    if (!markerUser) return;
    if (!markerMatchId) {
      setIsError(true);
      setMessage("Selecciona un partido");
      return;
    }
    setMarkerSaving(true);
    try {
      await api(`/admin/users/${markerUser.id}/predictions`, {
        method: "POST",
        body: JSON.stringify({
          matchId: Number(markerMatchId),
          predictedHomeScore: markerHome,
          predictedAwayScore: markerAway
        })
      });
      closeMarker();
      setIsError(false);
      setMessage("Marcador guardado");
      loadUsers();
    } catch (e) {
      setIsError(true);
      setMessage((e as Error).message);
    } finally {
      setMarkerSaving(false);
    }
  }

  function openLate(user: PollaUser) {
    setLateUser(user);
    setLateValue(user.lateStartPoints ?? 0);
  }

  function closeLate() {
    setLateUser(null);
  }

  async function saveLate(event: FormEvent) {
    event.preventDefault();
    if (!lateUser) return;
    setLateSaving(true);
    try {
      await api(`/admin/users/${lateUser.id}`, {
        method: "PATCH",
        body: JSON.stringify({ lateStartPoints: lateValue })
      });
      closeLate();
      setIsError(false);
      setMessage("Puntos por inicio tarde actualizados");
      loadUsers();
    } catch (e) {
      setIsError(true);
      setMessage((e as Error).message);
    } finally {
      setLateSaving(false);
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
          <div className="admin-users-actions">
            <label className="admin-users-toggle">
              <input
                type="checkbox"
                checked={showInactive}
                onChange={(e) => setShowInactive(e.target.checked)}
              />
              Mostrar inactivos{inactiveCount > 0 ? ` (${inactiveCount})` : ""}
            </label>
            <button type="button" className="btn btn-primary" onClick={openCreate}>
              Nuevo participante
            </button>
          </div>
        </div>

        <h2 style={{ fontSize: "1.15rem", marginBottom: "1rem" }}>
          Participantes ({filteredUsers.length}
          {filteredUsers.length !== users.length ? ` de ${users.length}` : ""})
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
                  <SortableTh label="Usuario" col="email" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} />
                  <SortableTh label="Pagado" col="amountPaid" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} />
                  <SortableTh label="Predicciones" col="predictionsCount" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} />
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map((u) => (
                  <tr key={u.id} className={rowClass(u)}>
                    <td>
                      <div className="user-identity">
                        <div className="user-identity__top">
                          <code className="user-code">{u.email}</code>
                          {u.role === "ADMIN" && <span className="badge badge-scheduled">Admin</span>}
                          {u.isActive ? (
                            <span className="badge badge-active">Activo</span>
                          ) : (
                            <span className="badge badge-inactive">Inactivo</span>
                          )}
                        </div>
                        <span className="user-identity__name">
                          {u.displayName || <span className="text-muted">—</span>}
                        </span>
                      </div>
                    </td>
                    <td>
                      {formatMoney(u.amountPaid)}
                      {u.isActive && u.role !== "ADMIN" && u.amountPaid <= 0 && (
                        <span className="badge badge-unpaid" style={{ marginLeft: 6 }}>
                          Sin pago
                        </span>
                      )}
                    </td>
                    <td>{u.predictionsCount}</td>
                    <td>
                      <div className="row-actions">
                        <button
                          type="button"
                          className="btn btn-ghost"
                          style={{ padding: "0.4rem 0.75rem", fontSize: "0.8rem" }}
                          onClick={(e) => openMenu(e, u)}
                        >
                          Acciones ▾
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      {menu && (
        <>
          <div className="actions-menu__backdrop" onClick={closeMenu} role="presentation" />
          <div className="actions-menu__list" style={{ top: menu.top, right: menu.right }}>
            <button
              type="button"
              className="actions-menu__item"
              onClick={() => {
                const u = menu.user;
                closeMenu();
                openEdit(u);
              }}
            >
              Editar
            </button>
            {menu.user.role !== "ADMIN" && (
              <button
                type="button"
                className={`actions-menu__item${menu.user.isActive ? " actions-menu__item--danger" : ""}`}
                onClick={() => {
                  const u = menu.user;
                  closeMenu();
                  toggleActive(u);
                }}
              >
                {menu.user.isActive ? "Desactivar" : "Activar"}
              </button>
            )}
            {menu.user.role !== "ADMIN" && (
              <>
                <div className="actions-menu__sep" />
                {revealExtrasId === menu.user.id ? (
                  <>
                    <button
                      type="button"
                      className="actions-menu__item"
                      onClick={() => {
                        const u = menu.user;
                        closeMenu();
                        openMarker(u);
                      }}
                    >
                      Marcador
                    </button>
                    <button
                      type="button"
                      className="actions-menu__item"
                      onClick={() => {
                        const u = menu.user;
                        closeMenu();
                        openLate(u);
                      }}
                    >
                      Inicio tarde
                    </button>
                  </>
                ) : (
                  <button
                    type="button"
                    className="actions-menu__item"
                    onClick={() => revealExtras(menu.user.id)}
                  >
                    Ver más…
                  </button>
                )}
              </>
            )}
          </div>
        </>
      )}

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

      <Modal
        title="Poner marcador (pronóstico)"
        open={markerUser !== null}
        onClose={closeMarker}
        footer={
          <>
            <button type="button" className="btn btn-ghost" onClick={closeMarker} disabled={markerSaving}>
              Cancelar
            </button>
            <button type="submit" form="marker-form" className="btn btn-primary" disabled={markerSaving}>
              {markerSaving ? "Guardando…" : "Guardar marcador"}
            </button>
          </>
        }
      >
        {markerUser && (
          <form id="marker-form" className="modal-form" onSubmit={saveMarker}>
            <p className="text-muted" style={{ marginTop: 0 }}>
              Usuario: <code className="user-code">{markerUser.email}</code>
              {markerUser.displayName ? ` — ${markerUser.displayName}` : ""}
            </p>
            <div className="field">
              <label htmlFor="marker-match">Partido</label>
              <select
                id="marker-match"
                className="input"
                value={markerMatchId}
                onChange={(e) => setMarkerMatchId(e.target.value)}
                required
              >
                <option value="">{matchesLoading ? "Cargando partidos…" : "Selecciona un partido"}</option>
                {matches.map((m) => (
                  <option key={m.id} value={m.id}>
                    {matchOptionLabel(m)}
                  </option>
                ))}
              </select>
            </div>
            <div className="field">
              <label htmlFor="marker-home">Marcador</label>
              <div style={{ display: "flex", gap: "0.5rem", alignItems: "center" }}>
                <input
                  id="marker-home"
                  className="input"
                  type="number"
                  min={0}
                  style={{ width: "5rem" }}
                  value={markerHome}
                  onChange={(e) => setMarkerHome(Number(e.target.value))}
                  aria-label="Goles local"
                />
                <span>-</span>
                <input
                  className="input"
                  type="number"
                  min={0}
                  style={{ width: "5rem" }}
                  value={markerAway}
                  onChange={(e) => setMarkerAway(Number(e.target.value))}
                  aria-label="Goles visitante"
                />
              </div>
            </div>
            <p className="text-muted" style={{ fontSize: "0.8rem" }}>
              El marcador solo se puede poner una vez; no se puede cambiar después.
            </p>
          </form>
        )}
      </Modal>

      <Modal
        title="Puntos por inicio tarde"
        open={lateUser !== null}
        onClose={closeLate}
        footer={
          <>
            <button type="button" className="btn btn-ghost" onClick={closeLate} disabled={lateSaving}>
              Cancelar
            </button>
            <button type="submit" form="late-form" className="btn btn-primary" disabled={lateSaving}>
              {lateSaving ? "Guardando…" : "Guardar puntos"}
            </button>
          </>
        }
      >
        {lateUser && (
          <form id="late-form" className="modal-form" onSubmit={saveLate}>
            <p className="text-muted" style={{ marginTop: 0 }}>
              Usuario: <code className="user-code">{lateUser.email}</code>
              {lateUser.displayName ? ` — ${lateUser.displayName}` : ""}
            </p>
            <div className="field">
              <label htmlFor="late-points">Puntos por inicio tarde</label>
              <input
                id="late-points"
                className="input"
                type="number"
                min={0}
                value={lateValue}
                onChange={(e) => setLateValue(Number(e.target.value))}
              />
              <p className="text-muted" style={{ fontSize: "0.8rem" }}>
                Se suman al total del usuario. Pon 0 para quitarlos.
              </p>
            </div>
          </form>
        )}
      </Modal>
    </>
  );
}
