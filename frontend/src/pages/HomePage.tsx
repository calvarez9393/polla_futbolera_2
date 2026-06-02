import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { GroupCard } from "../components/GroupCard";
import { api } from "../lib/api";
import { getToken } from "../lib/auth";

interface StandingItem {
  group_name: string;
  team_name: string;
  team_logo_url?: string | null;
  rank: number;
  points: number;
  played: number;
}

export function HomePage() {
  const [rows, setRows] = useState<StandingItem[]>([]);
  const token = getToken();

  useEffect(() => {
    api<StandingItem[]>("/standings")
      .then(setRows)
      .catch(() => setRows([]));
  }, []);

  const byGroup = useMemo(() => {
    const map = new Map<string, StandingItem[]>();
    for (const row of rows) {
      const list = map.get(row.group_name) ?? [];
      list.push(row);
      map.set(row.group_name, list);
    }
    return [...map.entries()].sort(([a], [b]) => a.localeCompare(b));
  }, [rows]);

  return (
    <>
      <h1 className="hero-title" style={{ marginBottom: "1.5rem" }}>
        Polla Futbolera Mundial
      </h1>
      <section className="hero">
        <div className="hero-visual">
          <img
            src="/hero-worldcup-2022.jpg"
            alt="Estadio Education City durante el Mundial Qatar 2022"
            loading="eager"
            decoding="async"
          />
        </div>
        <div className="hero-copy">
          <p>
            Predice marcadores, compite en el ranking y sigue cada grupo del torneo. Datos sincronizados,
            puntuación automática y panel táctico para vivir el mundial con tu equipo.
          </p>
          {token ? (
            <Link to="/predictions" className="btn btn-cta">
              Hacer predicción
            </Link>
          ) : (
            <Link to="/login" className="btn btn-cta">
              Entrar
            </Link>
          )}
        </div>
      </section>

      <p className="hero-tagline">Explora este mundial y sé testigo del momento.</p>

      <header className="section-head">
        <h2>Grupos del torneo</h2>
        <p>Consulta partidos y predicciones por día en Calendario.</p>
      </header>

      {byGroup.length === 0 ? (
        <div className="panel-card empty-state">
          <strong>Torneo pendiente de carga</strong>
          <p>Un administrador debe importar el calendario Mundial 2026 desde el panel Admin.</p>
          {token && (
            <Link to="/admin" className="btn btn-primary" style={{ marginTop: "1rem", display: "inline-flex" }}>
              Ir a Admin
            </Link>
          )}
        </div>
      ) : (
        <div className="groups-grid">
          {byGroup.map(([name, teams]) => (
            <GroupCard key={name} groupName={name} teams={teams} />
          ))}
        </div>
      )}
    </>
  );
}
