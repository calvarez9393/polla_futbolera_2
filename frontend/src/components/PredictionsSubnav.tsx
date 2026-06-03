import { NavLink } from "react-router-dom";
import { InfoModal } from "./InfoModal";

const predictionLinks = [
  { to: "/predictions", label: "Partidos", end: true },
  { to: "/predictions/bracket", label: "Eliminatorias" }
] as const;

const statsLinks = [
  { to: "/predictions/qualifiers", label: "Cuadro de 32" },
  { to: "/predictions/r16", label: "Dieciseisavos" },
  { to: "/predictions/extras", label: "Cuadro y premios" }
] as const;

function SubnavLink({
  to,
  label,
  end,
  primary
}: {
  to: string;
  label: string;
  end?: boolean;
  primary?: boolean;
}) {
  return (
    <NavLink
      to={to}
      end={end}
      className={({ isActive }) =>
        [
          "predictions-subnav-link",
          primary ? "predictions-subnav-link--primary" : "predictions-subnav-link--stats",
          isActive ? "predictions-subnav-link--active" : ""
        ]
          .filter(Boolean)
          .join(" ")
      }
    >
      {label}
    </NavLink>
  );
}

export function PredictionsSubnav() {
  return (
    <nav className="predictions-subnav" aria-label="Secciones de predicciones">
      <div className="predictions-subnav-block predictions-subnav-block--predict">
        <div className="predictions-subnav-label-row">
          <span className="predictions-subnav-label">Predicciones</span>
          <InfoModal title="Predicciones">
            <p>Aquí registras marcadores de partidos y cruces de eliminatorias.</p>
          </InfoModal>
        </div>
        <div className="predictions-subnav-links">
          {predictionLinks.map((item) => (
            <SubnavLink key={item.to} to={item.to} label={item.label} end={item.end} primary />
          ))}
        </div>
      </div>

      <div className="predictions-subnav-divider" aria-hidden="true" />

      <div className="predictions-subnav-block predictions-subnav-block--stats">
        <div className="predictions-subnav-label-row">
          <span className="predictions-subnav-label">Estadísticas</span>
          <InfoModal title="Estadísticas">
            <p>Cuadros, clasificados oficiales simulados y premios especiales del torneo.</p>
          </InfoModal>
        </div>
        <div className="predictions-subnav-links">
          {statsLinks.map((item) => (
            <SubnavLink key={item.to} to={item.to} label={item.label} />
          ))}
        </div>
      </div>
    </nav>
  );
}
