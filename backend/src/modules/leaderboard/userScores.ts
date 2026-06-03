import { pool } from "../../db/pool.js";

function formatExpertDayLabel(sourceId: number, breakdown: Record<string, unknown>): string {
  const fromBreakdown = breakdown.date;
  if (typeof fromBreakdown === "string" && fromBreakdown.length >= 10) {
    return fromBreakdown.slice(0, 10);
  }
  const raw = String(sourceId);
  if (raw.length === 8) {
    return `${raw.slice(0, 4)}-${raw.slice(4, 6)}-${raw.slice(6, 8)}`;
  }
  return raw;
}

function mapExtraScore(row: {
  source_type: string;
  source_id: number;
  points: number;
  breakdown: Record<string, unknown>;
  updated_at: Date;
}) {
  const breakdown = (row.breakdown ?? {}) as Record<string, unknown>;
  const base = {
    sourceType: row.source_type,
    sourceId: row.source_id,
    points: row.points as number,
    breakdown: breakdown as Record<string, number>,
    updatedAt: row.updated_at
  };

  switch (row.source_type) {
    case "QUALIFIERS":
      return {
        ...base,
        section: "qualifiers" as const,
        title: "Clasificados de grupos",
        description: "Aciertos entre los 24 directos (top 2 por grupo); el cuadro de dieciseisavos usa 32 equipos"
      };
    case "BONUSES":
      return {
        ...base,
        section: "bonuses" as const,
        title: "Cuadro y premios especiales",
        description: "Campeón, finalistas, goleador y premios del cuadro"
      };
    case "EXPERT_DAY": {
      const day = formatExpertDayLabel(row.source_id, breakdown);
      return {
        ...base,
        section: "phase1" as const,
        title: "Experto del día",
        description: `Jornada del ${day}: acertaste el 1X2 en todos los partidos del día`
      };
    }
    case "INVICTO":
      return {
        ...base,
        section: "phase1" as const,
        title: "Invicto",
        description: `Racha de ${breakdown.maxStreak ?? 10} aciertos consecutivos de resultado (1X2)`
      };
    case "GROUP_MASTER":
      return {
        ...base,
        section: "phase1" as const,
        title: `Maestro de grupo ${breakdown.groupName ?? ""}`.trim(),
        description: "Acertaste los 2 clasificados oficiales de este grupo"
      };
    default:
      return {
        ...base,
        section: "other" as const,
        title: row.source_type,
        description: null as string | null
      };
  }
}

export async function fetchUserScores(userId: number) {
  const totalResult = await pool.query(
    `SELECT COALESCE(SUM(points), 0)::int AS total_points
    FROM prediction_scores WHERE user_id = $1`,
    [userId]
  );
  const bySourceResult = await pool.query(
    `SELECT source_type, COALESCE(SUM(points), 0)::int AS points
    FROM prediction_scores WHERE user_id = $1
    GROUP BY source_type`,
    [userId]
  );
  const matchesResult = await pool.query(
    `SELECT
      ps.points,
      ps.breakdown,
      m.id AS match_id,
      m.starts_at,
      m.status,
      m.stage,
      m.round_key,
      m.round_label,
      m.home_score,
      m.away_score,
      g.name AS group_name,
      ht.name AS home_team_name,
      ht.logo_url AS home_team_logo_url,
      at.name AS away_team_name,
      at.logo_url AS away_team_logo_url,
      p.predicted_home_score,
      p.predicted_away_score
    FROM prediction_scores ps
    JOIN matches m ON m.id = ps.source_id AND ps.source_type = 'MATCH'
    JOIN teams ht ON ht.id = m.home_team_id
    JOIN teams at ON at.id = m.away_team_id
    LEFT JOIN groups g ON g.id = m.group_id
    LEFT JOIN predictions p ON p.match_id = m.id AND p.user_id = ps.user_id
    WHERE ps.user_id = $1
    ORDER BY m.starts_at DESC`,
    [userId]
  );
  const extrasResult = await pool.query(
    `SELECT source_type, source_id, points, breakdown, updated_at
    FROM prediction_scores
    WHERE user_id = $1 AND source_type <> 'MATCH'
    ORDER BY updated_at DESC`,
    [userId]
  );

  const totalsBySource: Record<string, number> = {};
  for (const row of bySourceResult.rows) {
    totalsBySource[row.source_type as string] = row.points as number;
  }

  const totalPoints = totalResult.rows[0].total_points as number;

  return {
    totalPoints,
    totalsBySource,
    matchPointsTotal: totalsBySource.MATCH ?? 0,
    extrasPointsTotal: totalPoints - (totalsBySource.MATCH ?? 0),
    matches: matchesResult.rows.map((row) => ({
      matchId: Number(row.match_id),
      startsAt: row.starts_at,
      status: row.status,
      stage: row.stage,
      roundKey: row.round_key,
      roundLabel: row.round_label,
      groupName: row.group_name,
      homeTeamName: row.home_team_name,
      homeTeamLogoUrl: row.home_team_logo_url,
      awayTeamName: row.away_team_name,
      awayTeamLogoUrl: row.away_team_logo_url,
      homeScore: row.home_score,
      awayScore: row.away_score,
      predictedHomeScore: row.predicted_home_score,
      predictedAwayScore: row.predicted_away_score,
      points: row.points,
      breakdown: row.breakdown
    })),
    extras: extrasResult.rows.map((row) =>
      mapExtraScore({
        source_type: row.source_type as string,
        source_id: row.source_id as number,
        points: row.points as number,
        breakdown: row.breakdown as Record<string, unknown>,
        updated_at: row.updated_at as Date
      })
    )
  };
}

export async function isLeaderboardParticipant(userId: number): Promise<boolean> {
  const result = await pool.query(
    `SELECT 1 FROM users WHERE id = $1 AND role = 'USER' LIMIT 1`,
    [userId]
  );
  return result.rowCount !== null && result.rowCount > 0;
}
