import { BREAKDOWN_LABELS } from "../lib/scoringLabels";

interface PointsChipsProps {
  breakdown: Record<string, number> | null | undefined;
  totalPoints?: number | null;
}

export function PointsChips({ breakdown, totalPoints }: PointsChipsProps) {
  const entries = breakdown ? Object.entries(breakdown).filter(([, pts]) => pts > 0) : [];
  const total =
    totalPoints ??
    (entries.length > 0 ? entries.reduce((sum, [, pts]) => sum + pts, 0) : 0);

  if (entries.length === 0 && total === 0) {
    return (
      <div className="points-chips">
        <span className="points-chip points-chip--muted">Sin puntos en este partido</span>
      </div>
    );
  }

  return (
    <div className="points-chips">
      {entries.map(([key, pts]) => (
        <span key={key} className="points-chip">
          <span className="points-chip-value">+{pts}</span>
          <span className="points-chip-label">{BREAKDOWN_LABELS[key] ?? key}</span>
        </span>
      ))}
      {total > 0 && (
        <span className="points-chip points-chip--total">
          <span className="points-chip-value">{total}</span>
          <span className="points-chip-label">pts total</span>
        </span>
      )}
    </div>
  );
}
