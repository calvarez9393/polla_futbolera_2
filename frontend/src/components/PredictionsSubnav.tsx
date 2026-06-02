import { NavLink } from "react-router-dom";

const links = [
  { to: "/predictions", label: "Partidos", end: true },
  { to: "/predictions/qualifiers", label: "Cuadro de 32" },
  { to: "/predictions/r16", label: "Dieciseisavos" },
  { to: "/predictions/bracket", label: "Eliminatorias" },
  { to: "/predictions/extras", label: "Cuadro y premios" }
];

export function PredictionsSubnav() {
  return (
    <nav className="filter-row" style={{ marginBottom: "1.25rem" }}>
      {links.map((item) => (
        <NavLink
          key={item.to}
          to={item.to}
          end={item.end}
          className={({ isActive }) => `btn btn-ghost${isActive ? " active-filter" : ""}`}
        >
          {item.label}
        </NavLink>
      ))}
    </nav>
  );
}
