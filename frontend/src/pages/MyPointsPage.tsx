import { Link } from "react-router-dom";
import { UserPointsDetail } from "../components/UserPointsDetail";
import { getToken } from "../lib/auth";

export function MyPointsPage() {
  const token = getToken();

  if (!token) {
    return (
      <div className="panel-card empty-state">
        <strong>Inicia sesión</strong>
        <p style={{ marginTop: "0.5rem" }}>
          <Link to="/login">Entrar</Link> para ver tus puntos.
        </p>
      </div>
    );
  }

  return (
    <>
      <h1 className="page-title">Mis puntos</h1>
      <p className="page-subtitle">
        Detalle de lo que ganaste en cada partido (marcador, 1X2, diferencia, etc.) y en clasificados, cuadro y
        bonos de la Fase 1. También en <Link to="/leaderboard">Ranking</Link>.
      </p>
      <UserPointsDetail />
    </>
  );
}
