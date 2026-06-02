import { Link, NavLink, useNavigate } from "react-router-dom";
import { clearSession, getToken, getUser } from "../lib/auth";

const publicLinks = [
  { to: "/", label: "Inicio", end: true as const },
  { to: "/standings", label: "Grupos" },
  { to: "/leaderboard", label: "Ranking" }
];

export function Navbar() {
  const navigate = useNavigate();
  const token = getToken();
  const user = getUser();

  const links = token
    ? [
        ...publicLinks,
        { to: "/predictions", label: "Predicciones" as const },
        { to: "/my-points", label: "Mis puntos" as const }
      ]
    : publicLinks;

  return (
    <header className="top-nav">
      <Link to="/" className="logo">
        Polla<span>Fut</span>
      </Link>

      <nav className="nav-center">
        {links.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={"end" in item ? item.end : false}
            className={({ isActive }) => `nav-item${isActive ? " active" : ""}`}
          >
            {item.label}
          </NavLink>
        ))}
        {token && user?.role === "ADMIN" && (
          <>
            <NavLink to="/admin/calendar" className={({ isActive }) => `nav-item${isActive ? " active" : ""}`}>
              Resultados
            </NavLink>
            <NavLink to="/admin/users" className={({ isActive }) => `nav-item${isActive ? " active" : ""}`}>
              Usuarios
            </NavLink>
            <NavLink to="/admin" className={({ isActive }) => `nav-item${isActive ? " active" : ""}`}>
              Admin
            </NavLink>
          </>
        )}
      </nav>

      <div className="nav-actions">
        {token ? (
          <>
            <span className="user-pill">{user?.email}</span>
            <button
              type="button"
              className="btn btn-ghost"
              onClick={() => {
                clearSession();
                navigate("/");
              }}
            >
              Salir
            </button>
          </>
        ) : (
          <Link to="/login" className="btn btn-ghost">
            Entrar
          </Link>
        )}
      </div>
    </header>
  );
}
