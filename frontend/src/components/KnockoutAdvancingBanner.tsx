import { TeamFlag } from "./TeamFlag";

interface KnockoutAdvancingBannerProps {
  teamName: string;
  logoUrl?: string | null;
  nextRoundLabel: string;
  viaPenalties?: boolean;
  compact?: boolean;
}

export function KnockoutAdvancingBanner({
  teamName,
  logoUrl,
  nextRoundLabel,
  viaPenalties = false,
  compact = false
}: KnockoutAdvancingBannerProps) {
  return (
    <p className={`knockout-advancing-banner${compact ? " knockout-advancing-banner--compact" : ""}`}>
      <span className="knockout-advancing-label">Pasa a {nextRoundLabel}:</span>
      <span className="knockout-advancing-team">
        <TeamFlag name={teamName} logoUrl={logoUrl} size="sm" />
        <strong>{teamName}</strong>
        {viaPenalties && <span className="knockout-advancing-pen"> (penales)</span>}
      </span>
    </p>
  );
}
