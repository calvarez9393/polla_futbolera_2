export const matchSelectFields = `
  m.id,
  m.external_id,
  m.stage,
  m.round_key,
  m.status,
  m.starts_at,
  m.calendar_date,
  m.kickoff_time_local,
  m.round_label,
  m.matchday,
  m.prediction_lock_at,
  m.home_score,
  m.away_score,
  m.winner_team_id,
  m.score_multiplier,
  m.group_id,
  g.name AS group_name,
  ht.id AS home_team_id,
  ht.name AS home_team_name,
  ht.logo_url AS home_team_logo_url,
  at.id AS away_team_id,
  at.name AS away_team_name,
  at.logo_url AS away_team_logo_url
`;

export const matchFromClause = `
  FROM matches m
  JOIN teams ht ON ht.id = m.home_team_id
  JOIN teams at ON at.id = m.away_team_id
  LEFT JOIN groups g ON g.id = m.group_id
`;

export function activeTournamentCondition(alias: string, paramIndex: number): string {
  return `${alias}.tournament_id = $${paramIndex}`;
}
