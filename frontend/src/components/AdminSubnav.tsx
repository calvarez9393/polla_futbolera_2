import { NavLink } from "react-router-dom";

const links = [
  { to: "/admin/calendar", label: "Calendario y resultados" },
  { to: "/admin/official", label: "Oficiales y bonos" },
  { to: "/admin/users", label: "Usuarios" },
  { to: "/admin", label: "Configuración", end: true }
];

export function AdminSubnav() {
  return (
    <nav className="admin-subnav">
      {links.map((item) => (
        <NavLink
          key={item.to}
          to={item.to}
          end={"end" in item ? item.end : false}
          className={({ isActive }) => `admin-subnav-link${isActive ? " active" : ""}`}
        >
          {item.label}
        </NavLink>
      ))}
    </nav>
  );
}
