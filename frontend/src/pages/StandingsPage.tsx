import { useEffect, useMemo, useState } from "react";
import { GroupCard } from "../components/GroupCard";
import { api } from "../lib/api";

interface StandingItem {
  group_name: string;
  team_name: string;
  team_logo_url?: string | null;
  rank: number;
  points: number;
  played: number;
}

export function StandingsPage() {
  const [rows, setRows] = useState<StandingItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api<StandingItem[]>("/standings")
      .then(setRows)
      .catch(() => setRows([]))
      .finally(() => setLoading(false));
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
      <h1 className="page-title">Tablas de grupos</h1>
      <p className="page-subtitle">Clasificación completa del torneo — compara con tus predicciones de fase de grupos.</p>

      {loading && (
        <div className="panel-card empty-state">
          <strong>Cargando…</strong>
        </div>
      )}

      {!loading && byGroup.length === 0 && (
        <div className="panel-card empty-state">
          <strong>Sin datos de grupos</strong>
          <p>Sincroniza el torneo desde Admin para ver las tablas.</p>
        </div>
      )}

      <div className="groups-grid">
        {byGroup.map(([name, teams]) => (
          <GroupCard key={name} groupName={name} teams={teams} />
        ))}
      </div>
    </>
  );
}
