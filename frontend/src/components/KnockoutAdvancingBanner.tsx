import { TeamFlag } from "./TeamFlag";

interface KnockoutAdvancingBannerProps {
  teamName: string;
  logoUrl?: string | null;
  nextRoundLabel: string;
  viaPenalties?: boolean;
  compact?: boolean;
  kind?: "prediction" | "official";
}

export function KnockoutAdvancingBanner({
  teamName,
  logoUrl,
  nextRoundLabel,
  viaPenalties = false,
  compact = false,
  kind = "prediction"
}: KnockoutAdvancingBannerProps) {
  const label =
    kind === "official"
      ? `Pasa de verdad a ${nextRoundLabel}`
      : `Tu predicción — pasa a ${nextRoundLabel}`;

  return (
    <p
      className={`knockout-advancing-banner knockout-advancing-banner--${kind}${compact ? " knockout-advancing-banner--compact" : ""}`}
    >
      <span className="knockout-advancing-label">{label}:</span>
      <span className="knockout-advancing-team">
        <TeamFlag name={teamName} logoUrl={logoUrl} size="sm" />
        <strong>{teamName}</strong>
        {viaPenalties && <span className="knockout-advancing-pen"> (penales)</span>}
      </span>
    </p>
  );
}
