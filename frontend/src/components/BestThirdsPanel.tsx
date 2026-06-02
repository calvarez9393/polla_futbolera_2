interface ThirdRow {
  teamId: number;
  name: string;
  groupName: string;
  points: number;
  goalDiff: number;
  goalsFor: number;
  assignedToMatch: number | null;
}

interface QualifiersSummary {
  bestThirds: ThirdRow[];
  allThirdsCount: number;
  directQualifiersCount: number;
  thirdSlotsAssigned: number;
  finishedGroupMatches?: number;
  groupsWithFullTable?: number;
}

export function BestThirdsPanel({
  qualifiers,
  variant = "predicted"
}: {
  qualifiers: QualifiersSummary;
  variant?: "predicted" | "official";
}) {
  if (qualifiers.bestThirds.length === 0) {
    return (
      <div className="panel-card" style={{ marginBottom: "1rem" }}>
        <h2 style={{ fontSize: "1rem", marginBottom: "0.5rem" }}>8 mejores terceros</h2>
        <p className="admin-block-hint">
          {variant === "predicted"
            ? "Completa predicciones en todos los grupos para calcular los 8 mejores terceros y llenar las ranuras del cuadro."
            : "Finaliza partidos de la fase de grupos para calcular los 8 mejores terceros."}
        </p>
      </div>
    );
  }

  return (
    <section className="panel-card best-thirds-panel" style={{ marginBottom: "1rem" }}>
      <h2 style={{ fontSize: "1rem", marginBottom: "0.5rem" }}>8 mejores terceros (FIFA)</h2>
      <p className="admin-block-hint" style={{ marginBottom: "0.75rem" }}>
        {qualifiers.directQualifiersCount} clasificados directos (top 2 × 12 grupos) +{" "}
        <strong>{qualifiers.bestThirds.length}</strong> terceros al cuadro de 32. Ranuras de 3º en
        partidos 74, 77, 79, 80, 81, 82, 85, 87:{" "}
        <strong>
          {qualifiers.thirdSlotsAssigned}/8 asignadas
        </strong>
        .
        {variant === "official" && qualifiers.finishedGroupMatches != null && (
          <>
            {" "}
            Partidos de grupo finalizados: {qualifiers.finishedGroupMatches}
            {qualifiers.groupsWithFullTable != null &&
              ` · Grupos completos: ${qualifiers.groupsWithFullTable}/12`}
            .
          </>
        )}
      </p>
      <ol className="best-thirds-list">
        {qualifiers.bestThirds.map((t, i) => (
          <li key={t.teamId}>
            <span className="best-thirds-rank">{i + 1}.</span>
            <span>
              <strong>{t.name}</strong> — Grupo {t.groupName} ({t.points} pts, DG{" "}
              {t.goalDiff > 0 ? `+${t.goalDiff}` : t.goalDiff})
              {t.assignedToMatch != null && (
                <span className="best-thirds-assigned"> → Partido {t.assignedToMatch}</span>
              )}
              {t.assignedToMatch == null && (
                <span className="best-thirds-unassigned"> (sin ranura aún)</span>
              )}
            </span>
          </li>
        ))}
      </ol>
    </section>
  );
}
