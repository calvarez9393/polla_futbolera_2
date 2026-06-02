import { pool } from "../../db/pool.js";
import {
  matchCalendarDateSql,
  parseCalendarYmd,
  phase1MatchSql,
  ymdToExpertDaySourceId
} from "../matches/calendarDate.js";
import { getActiveTournamentId } from "../settings/service.js";
import { ensureOfficialQualifiedTeams } from "./qualifiers.js";
import { loadOfficialScoringRules } from "./loadRules.js";
import { isPhase1Round, resolveRoundKey } from "./rulesConfig.js";

function getOutcome(home: number, away: number): "HOME" | "AWAY" | "DRAW" {
  if (home === away) return "DRAW";
  return home > away ? "HOME" : "AWAY";
}

function outcomeCorrect(
  predHome: number,
  predAway: number,
  realHome: number,
  realAway: number
): boolean {
  return getOutcome(predHome, predAway) === getOutcome(realHome, realAway);
}

/**
 * Bono experto del día: por cada jornada (fecha de calendario) en la que el usuario
 * acierta el 1X2 en todos los partidos de Fase 1 de ese día.
 * source_id = YYYYMMDD (una fila por usuario y por día).
 */
export async function calculateExpertDayBonuses(): Promise<{ awards: number; daysProcessed: number }> {
  const rules = await loadOfficialScoringRules();
  const tournamentId = await getActiveTournamentId();
  if (!tournamentId) return { awards: 0, daysProcessed: 0 };

  const calDate = matchCalendarDateSql("m");
  const phase1 = phase1MatchSql("m");

  await pool.query(`DELETE FROM prediction_scores WHERE source_type = 'EXPERT_DAY'`);

  const days = await pool.query(
    `SELECT match_date FROM (
      SELECT ${calDate} AS match_date,
        COUNT(*)::int AS total,
        COUNT(*) FILTER (
          WHERE status = 'FINISHED' AND home_score IS NOT NULL AND away_score IS NOT NULL
        )::int AS finished
      FROM matches m
      WHERE m.tournament_id = $1 AND ${phase1}
      GROUP BY ${calDate}
    ) d
    WHERE finished = total AND total > 0
    ORDER BY match_date`,
    [tournamentId]
  );

  let awards = 0;
  for (const { match_date } of days.rows) {
    const ymd = parseCalendarYmd(match_date);
    const sourceId = ymdToExpertDaySourceId(ymd);

    const matches = await pool.query(
      `SELECT m.id, m.home_score, m.away_score
      FROM matches m
      WHERE m.tournament_id = $1
        AND ${calDate} = $2::date
        AND ${phase1}
        AND m.status = 'FINISHED'
        AND m.home_score IS NOT NULL
        AND m.away_score IS NOT NULL
      ORDER BY m.starts_at`,
      [tournamentId, ymd]
    );
    if (matches.rows.length === 0) continue;

    const matchIds = matches.rows.map((r) => Number(r.id));
    const users = await pool.query(
      `SELECT DISTINCT p.user_id
      FROM predictions p
      JOIN users u ON u.id = p.user_id
      WHERE p.match_id = ANY($1::bigint[]) AND u.role IN ('USER', 'ADMIN')`,
      [matchIds]
    );

    for (const { user_id } of users.rows) {
      const userId = Number(user_id);
      const preds = await pool.query(
        `SELECT p.match_id, p.predicted_home_score, p.predicted_away_score,
          m.home_score, m.away_score
        FROM predictions p
        JOIN matches m ON m.id = p.match_id
        WHERE p.user_id = $1 AND p.match_id = ANY($2::bigint[])`,
        [userId, matchIds]
      );
      if (preds.rows.length !== matchIds.length) continue;

      const allCorrect = preds.rows.every((row) =>
        outcomeCorrect(
          Number(row.predicted_home_score),
          Number(row.predicted_away_score),
          Number(row.home_score),
          Number(row.away_score)
        )
      );
      if (!allCorrect) continue;

      await pool.query(
        `INSERT INTO prediction_scores (user_id, source_type, source_id, points, breakdown)
        VALUES ($1, 'EXPERT_DAY', $2, $3, $4::jsonb)
        ON CONFLICT (user_id, source_type, source_id)
        DO UPDATE SET points = EXCLUDED.points, breakdown = EXCLUDED.breakdown, updated_at = NOW()`,
        [
          userId,
          sourceId,
          rules.expert_day_bonus,
          JSON.stringify({ expertDay: rules.expert_day_bonus, date: ymd })
        ]
      );
      awards += 1;
    }
  }

  return { awards, daysProcessed: days.rows.length };
}

/** Bono invicto: 10 aciertos de resultado consecutivos (orden cronológico). */
export async function calculateInvictoBonuses(): Promise<{ usersAwarded: number }> {
  const rules = await loadOfficialScoringRules();
  const users = await pool.query(`SELECT id FROM users WHERE role IN ('USER', 'ADMIN')`);

  let usersAwarded = 0;
  for (const { id: userId } of users.rows) {
    const uid = Number(userId);
    const preds = await pool.query(
      `SELECT p.predicted_home_score, p.predicted_away_score,
        m.home_score, m.away_score, m.starts_at, m.round_key, m.stage, m.round_label
      FROM predictions p
      JOIN matches m ON m.id = p.match_id
      WHERE p.user_id = $1
        AND m.status = 'FINISHED'
        AND m.home_score IS NOT NULL
        AND m.away_score IS NOT NULL
      ORDER BY m.starts_at ASC`,
      [uid]
    );

    let streak = 0;
    let maxStreak = 0;
    for (const row of preds.rows) {
      const roundKey = resolveRoundKey(row);
      if (!isPhase1Round(roundKey)) {
        streak = 0;
        continue;
      }
      if (
        outcomeCorrect(
          Number(row.predicted_home_score),
          Number(row.predicted_away_score),
          Number(row.home_score),
          Number(row.away_score)
        )
      ) {
        streak += 1;
        maxStreak = Math.max(maxStreak, streak);
      } else {
        streak = 0;
      }
    }

    if (maxStreak < 10) continue;

    await pool.query(
      `INSERT INTO prediction_scores (user_id, source_type, source_id, points, breakdown)
      VALUES ($1, 'INVICTO', 0, $2, $3::jsonb)
      ON CONFLICT (user_id, source_type, source_id)
      DO UPDATE SET points = EXCLUDED.points, breakdown = EXCLUDED.breakdown, updated_at = NOW()`,
      [uid, rules.invicto_bonus, JSON.stringify({ invicto: rules.invicto_bonus, maxStreak })]
    );
    usersAwarded += 1;
  }
  return { usersAwarded };
}

/** Bono maestro de grupo: acertar los 2 clasificados oficiales de un grupo. */
export async function calculateGroupMasterBonuses(): Promise<{ awards: number }> {
  const official = await ensureOfficialQualifiedTeams();

  const rules = await loadOfficialScoringRules();
  const groups = await pool.query(
    `SELECT g.id AS group_id, g.name AS group_name,
      ARRAY_AGG(s.team_id ORDER BY s.rank) FILTER (WHERE s.team_id = ANY($1::bigint[])) AS official_team_ids
    FROM groups g
    JOIN standings s ON s.group_id = g.id
    WHERE s.team_id = ANY($1::bigint[])
    GROUP BY g.id, g.name
    HAVING COUNT(DISTINCT s.team_id) FILTER (WHERE s.team_id = ANY($1::bigint[])) = 2`,
    [official]
  );

  let awards = 0;
  for (const group of groups.rows) {
    const groupId = Number(group.group_id);
    const officialPair = ((group.official_team_ids as number[]) ?? []).map(Number);
    if (officialPair.length !== 2) continue;

    const users = await pool.query(
      `SELECT DISTINCT qp.user_id
      FROM qualifier_predictions qp
      JOIN users u ON u.id = qp.user_id
      WHERE qp.team_id = ANY($1::bigint[]) AND u.role IN ('USER', 'ADMIN')`,
      [officialPair]
    );

    for (const { user_id } of users.rows) {
      const userId = Number(user_id);
      const picks = await pool.query(
        `SELECT team_id FROM qualifier_predictions
        WHERE user_id = $1 AND team_id = ANY($2::bigint[])`,
        [userId, officialPair]
      );
      const picked = new Set(picks.rows.map((r) => Number(r.team_id)));
      if (!officialPair.every((id) => picked.has(id))) continue;

      await pool.query(
        `INSERT INTO prediction_scores (user_id, source_type, source_id, points, breakdown)
        VALUES ($1, 'GROUP_MASTER', $2, $3, $4::jsonb)
        ON CONFLICT (user_id, source_type, source_id)
        DO UPDATE SET points = EXCLUDED.points, breakdown = EXCLUDED.breakdown, updated_at = NOW()`,
        [
          userId,
          groupId,
          rules.group_master_bonus,
          JSON.stringify({
            groupMaster: rules.group_master_bonus,
            groupName: group.group_name
          })
        ]
      );
      awards += 1;
    }
  }
  return { awards };
}

/** Invicto y maestro de grupo (requiere 24 clasificados; se intentan tomar de tablas oficiales). */
export async function calculateInvictoAndGroupMasterBonuses(): Promise<{
  invictoUsers: number;
  groupMasterAwards: number;
}> {
  const invicto = await calculateInvictoBonuses();
  const groupMaster = await calculateGroupMasterBonuses();
  return {
    invictoUsers: invicto.usersAwarded,
    groupMasterAwards: groupMaster.awards
  };
}
