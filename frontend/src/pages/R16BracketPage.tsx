import { useCallback, useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { PredictionsSubnav } from "../components/PredictionsSubnav";
import { BestThirdsPanel } from "../components/BestThirdsPanel";
import { BracketTreeView, type BracketTreeMatch } from "../components/BracketTreeView";
import { R16BracketGrid } from "../components/R16BracketGrid";
import { api } from "../lib/api";
import type { BracketTreePair } from "../lib/wc2026BracketTree";

interface QualifiersSummary {
  bestThirds: Array<{
    teamId: number;
    name: string;
    groupName: string;
    points: number;
    goalDiff: number;
    goalsFor: number;
    assignedToMatch: number | null;
  }>;
  allThirdsCount: number;
  directQualifiersCount: number;
  thirdSlotsAssigned: number;
  finishedGroupMatches?: number;
  groupsWithFullTable?: number;
}

type LayoutMode = "tree" | "list";

export function R16BracketPage() {
  const [layout, setLayout] = useState<LayoutMode>("tree");
  const [official, setOfficial] = useState<{
    matches: BracketTreeMatch[];
    hasKnockout: boolean;
    tree: { pairs: BracketTreePair[] };
    qualifiers: QualifiersSummary | null;
  } | null>(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await api<typeof official>("/matches/r16-bracket");
      setOfficial(data);
    } catch {
      setOfficial(null);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load().catch(() => undefined);
  }, [load]);

  const officialComplete =
    official?.matches.filter((m) => m.home && m.away).length ?? 0;

  return (
    <>
      <h1 className="page-title">Dieciseisavos de final</h1>
      <p className="page-subtitle">
        Cuadro <strong>oficial</strong> FIFA (partidos 73–88). Lo publica el administrador según los resultados reales
        de grupos. Tus predicciones de marcador en esta fase van en{" "}
        <Link to="/predictions/bracket">Eliminatorias</Link>.
      </p>

      <PredictionsSubnav />

      <div className="filter-row" style={{ marginBottom: "1rem" }}>
        <button
          type="button"
          className={`btn btn-ghost${layout === "tree" ? " active-filter" : ""}`}
          onClick={() => setLayout("tree")}
        >
          Ramificación
        </button>
        <button
          type="button"
          className={`btn btn-ghost${layout === "list" ? " active-filter" : ""}`}
          onClick={() => setLayout("list")}
        >
          Lista
        </button>
      </div>

      {loading && (
        <div className="panel-card empty-state">
          <strong>Cargando…</strong>
        </div>
      )}

      {!loading && official && (
        <>
          {officialComplete < 16 && (
            <div className="panel-card" style={{ marginBottom: "1rem" }}>
              <p className="admin-block-hint">
                El cuadro oficial aún no está completo ({officialComplete}/16). El administrador lo publicará en{" "}
                <Link to="/admin/official">Resultados oficiales</Link>.
              </p>
            </div>
          )}
          {official.qualifiers && (
            <BestThirdsPanel qualifiers={official.qualifiers} variant="official" />
          )}
          {layout === "tree" ? (
            <BracketTreeView
              matches={official.matches.map((m) => ({
                ...m,
                isOfficial: m.home != null && m.away != null
              }))}
              tree={official.tree}
            />
          ) : (
            <R16BracketGrid
              matches={official.matches.map((m) => ({
                ...m,
                isOfficial: m.home != null && m.away != null
              }))}
              emptyHint="Importa eliminatorias y define el cuadro en el panel admin."
            />
          )}
        </>
      )}
    </>
  );
}
