import { BREAKDOWN_LABELS } from "../lib/scoringLabels";

interface PointsBreakdownListProps {
  breakdown: Record<string, number> | null | undefined;
  emptyLabel?: string;
}

export function PointsBreakdownList({
  breakdown,
  emptyLabel = "Sin desglose"
}: PointsBreakdownListProps) {
  const entries = breakdown
    ? Object.entries(breakdown).filter(([, pts]) => typeof pts === "number" && pts > 0)
    : [];

  if (entries.length === 0) {
    return <p className="points-breakdown-empty">{emptyLabel}</p>;
  }

  return (
    <ul className="points-breakdown-list">
      {entries.map(([key, pts]) => (
        <li key={key} className="points-breakdown-row">
          <span className="points-breakdown-label">{BREAKDOWN_LABELS[key] ?? key}</span>
          <span className="points-breakdown-value">+{pts} pts</span>
        </li>
      ))}
    </ul>
  );
}
