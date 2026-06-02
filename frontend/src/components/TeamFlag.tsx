import { teamFlagSrc } from "../lib/teamFlags";

interface TeamFlagProps {
  name: string;
  logoUrl?: string | null;
  size?: "sm" | "md" | "lg";
  className?: string;
}

const SIZES = { sm: 24, md: 32, lg: 40 } as const;

function initials(name: string): string {
  return name
    .split(/\s+/)
    .map((w) => w[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();
}

export function TeamFlag({ name, logoUrl, size = "md", className = "" }: TeamFlagProps) {
  const px = SIZES[size];
  const src = teamFlagSrc(name, logoUrl, px * 2);

  return (
    <span
      className={`team-flag team-flag--${size}${className ? ` ${className}` : ""}`}
      title={name}
      aria-hidden
    >
      {src ? (
        <img src={src} alt="" width={px} height={Math.round(px * 0.75)} loading="lazy" decoding="async" />
      ) : (
        <span className="team-flag-fallback">{initials(name)}</span>
      )}
    </span>
  );
}
