import { pool } from "../../db/pool.js";
import {
  predictedMatchupFromRow,
  officialMatchupFromRow,
} from "../bracket/resolveUserSlotTeams.js";
import {
  matchCalendarDateSql,
  matchLocalScheduleParts,
} from "../matches/calendarDate.js";
import { getOfficialBonusResults } from "../scoring/bonuses.js";

interface BonusExtrasContext {
  topScorerPick: string | null;
  topScorerOfficial: string | null;
  topScorerCorrect: boolean | null;
  topAssisterPick: string | null;
  topAssisterOfficial: string | null;
  topAssisterCorrect: boolean | null;
}

function formatExpertDayLabel(
  sourceId: number,
  breakdown: Record<string, unknown>,
): string {
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

function mapExtraScore(
  row: {
    source_type: string;
    source_id: number;
    points: number;
    breakdown: Record<string, unknown>;
    updated_at: Date;
  },
  bonusExtras?: BonusExtrasContext,
) {
  const breakdown = (row.breakdown ?? {}) as Record<string, unknown>;
  const base = {
    sourceType: row.source_type,
    sourceId: row.source_id,
    points: row.points as number,
    breakdown: breakdown as Record<string, number>,
    updatedAt: row.updated_at,
  };

  switch (row.source_type) {
    case "QUALIFIERS":
      return {
        ...base,
        section: "qualifiers" as const,
        title: "Clasificados de grupos",
        description:
          "Aciertos entre los 24 directos (top 2 por grupo); el cuadro de dieciseisavos usa 32 equipos",
      };
    case "BONUSES":
      return {
        ...base,
        section: "bonuses" as const,
        title: "Cuadro y premios especiales",
        description: "Campeón, finalistas, goleador y premios del cuadro",
        topScorerPick: bonusExtras?.topScorerPick ?? null,
        topScorerOfficial: bonusExtras?.topScorerOfficial ?? null,
        topScorerCorrect: bonusExtras?.topScorerCorrect ?? null,
        topAssisterPick: bonusExtras?.topAssisterPick ?? null,
        topAssisterOfficial: bonusExtras?.topAssisterOfficial ?? null,
        topAssisterCorrect: bonusExtras?.topAssisterCorrect ?? null,
      };
    case "EXPERT_DAY": {
      const day = formatExpertDayLabel(row.source_id, breakdown);
      return {
        ...base,
        section: "phase1" as const,
        title: "Experto del día",
        description: `Jornada del ${day}: acertaste el 1X2 en todos los partidos del día`,
      };
    }
    case "INVICTO":
      return {
        ...base,
        section: "phase1" as const,
        title: "Invicto",
        description: `Racha de ${breakdown.maxStreak ?? 10} aciertos consecutivos de resultado (1X2)`,
      };
    case "GROUP_MASTER":
      return {
        ...base,
        section: "phase1" as const,
        title: `Maestro de grupo ${breakdown.groupName ?? ""}`.trim(),
        description: "Acertaste los 2 clasificados oficiales de este grupo",
      };
    case "LATE_START":
      return {
        ...base,
        section: "other" as const,
        title: "Puntos por inicio tarde",
        description:
          "Puntos asignados manualmente por ingresar tarde a la polla",
      };
    default:
      return {
        ...base,
        section: "other" as const,
        title: row.source_type,
        description: null as string | null,
      };
  }
}

function resolvePredictedAdvancing(
  row: Record<string, unknown>,
  predictedMatchup: ReturnType<typeof predictedMatchupFromRow>,
): {
  teamName: string;
  teamLogoUrl: string | null;
  viaPenalties: boolean;
} | null {
  if (
    row.stage !== "KNOCKOUT" ||
    row.predicted_home_score == null ||
    !predictedMatchup
  ) {
    return null;
  }

  const ph = row.predicted_home_score as number;
  const pa = row.predicted_away_score as number;
  const viaPenalties = ph === pa;

  if (row.predicted_advancing_team_id && row.predicted_advancing_team_name) {
    return {
      teamName: row.predicted_advancing_team_name as string,
      teamLogoUrl:
        (row.predicted_advancing_team_logo_url as string | null) ?? null,
      viaPenalties,
    };
  }

  if (ph !== pa) {
    const homeWins = ph > pa;
    return {
      teamName: homeWins
        ? predictedMatchup.homeTeamName
        : predictedMatchup.awayTeamName,
      teamLogoUrl: homeWins
        ? (predictedMatchup.homeTeamLogoUrl ?? null)
        : (predictedMatchup.awayTeamLogoUrl ?? null),
      viaPenalties: false,
    };
  }

  return null;
}

function nextRoundLabelFromKey(roundKey: string | null | undefined): string {
  switch (roundKey?.toUpperCase()) {
    case "R16":
      return "octavos de final";
    case "R8":
      return "cuartos de final";
    case "R4":
      return "semifinal";
    case "SF":
      return "la final";
    case "F":
      return "el campeonato";
    case "TP3":
      return "3.er puesto";
    default:
      return "siguiente ronda";
  }
}

export async function fetchUserScores(userId: number) {
  const totalResult = await pool.query(
    `SELECT COALESCE(SUM(points), 0)::int AS total_points
    FROM prediction_scores WHERE user_id = $1`,
    [userId],
  );
  const bySourceResult = await pool.query(
    `SELECT source_type, COALESCE(SUM(points), 0)::int AS points
    FROM prediction_scores WHERE user_id = $1
    GROUP BY source_type`,
    [userId],
  );
  const matchesResult = await pool.query(
    `SELECT
      ps.points,
      ps.breakdown,
      m.id AS match_id,
      m.starts_at,
      m.calendar_date,
      m.kickoff_time_local,
      m.status,
      m.stage,
      m.round_key,
      m.round_label,
      m.home_score,
      m.away_score,
      m.home_team_id,
      m.away_team_id,
      m.winner_team_id,
      g.name AS group_name,
      ht.name AS home_team_name,
      ht.logo_url AS home_team_logo_url,
      at.name AS away_team_name,
      at.logo_url AS away_team_logo_url,
      p.predicted_home_score,
      p.predicted_away_score,
      p.predicted_advancing_team_id,
      p.bracket_home_team_id,
      p.bracket_away_team_id,
      bht.name AS bracket_home_team_name,
      bht.logo_url AS bracket_home_team_logo_url,
      bat.name AS bracket_away_team_name,
      bat.logo_url AS bracket_away_team_logo_url,
      padv.name AS predicted_advancing_team_name,
      padv.logo_url AS predicted_advancing_team_logo_url,
      wt.name AS official_advancing_team_name,
      wt.logo_url AS official_advancing_team_logo_url
    FROM prediction_scores ps
    JOIN matches m ON m.id = ps.source_id AND ps.source_type = 'MATCH'
    JOIN teams ht ON ht.id = m.home_team_id
    JOIN teams at ON at.id = m.away_team_id
    LEFT JOIN groups g ON g.id = m.group_id
    LEFT JOIN predictions p ON p.match_id = m.id AND p.user_id = ps.user_id
    LEFT JOIN teams bht ON bht.id = p.bracket_home_team_id
    LEFT JOIN teams bat ON bat.id = p.bracket_away_team_id
    LEFT JOIN teams padv ON padv.id = p.predicted_advancing_team_id
    LEFT JOIN teams wt ON wt.id = m.winner_team_id
    WHERE ps.user_id = $1
    ORDER BY ${matchCalendarDateSql("m")} DESC,
             COALESCE(m.kickoff_time_local, to_char(m.starts_at AT TIME ZONE 'UTC', 'HH24:MI')) DESC,
             m.id DESC`,
    [userId],
  );
  const extrasResult = await pool.query(
    `SELECT source_type, source_id, points, breakdown, updated_at
    FROM prediction_scores
    WHERE user_id = $1 AND source_type <> 'MATCH'
    ORDER BY updated_at DESC`,
    [userId],
  );
  const bonusRow = await pool.query(
    `SELECT top_scorer, top_scorer_correct, top_assister, top_assister_correct
    FROM bonus_predictions WHERE user_id = $1`,
    [userId],
  );
  const official = await getOfficialBonusResults();
  const bonusExtras: BonusExtrasContext = {
    topScorerPick: bonusRow.rows[0]?.top_scorer ?? null,
    topScorerOfficial: official.topScorer ?? null,
    topScorerCorrect: bonusRow.rows[0]?.top_scorer_correct ?? null,
    topAssisterPick: bonusRow.rows[0]?.top_assister ?? null,
    topAssisterOfficial: official.topAssister ?? null,
    topAssisterCorrect: bonusRow.rows[0]?.top_assister_correct ?? null,
  };

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
    matches: matchesResult.rows.map((row) => {
      const predictedMatchup = predictedMatchupFromRow({
        stage: row.stage as string,
        predicted_home_score: row.predicted_home_score as number | null,
        bracket_home_team_id: row.bracket_home_team_id as number | null,
        bracket_away_team_id: row.bracket_away_team_id as number | null,
        bracket_home_team_name: row.bracket_home_team_name as string | null,
        bracket_away_team_name: row.bracket_away_team_name as string | null,
        bracket_home_team_logo_url: row.bracket_home_team_logo_url as
          | string
          | null,
        bracket_away_team_logo_url: row.bracket_away_team_logo_url as
          | string
          | null,
        home_team_id: row.home_team_id,
        away_team_id: row.away_team_id,
        home_team_name: row.home_team_name as string,
        away_team_name: row.away_team_name as string,
        home_team_logo_url: row.home_team_logo_url as string | null,
        away_team_logo_url: row.away_team_logo_url as string | null,
      });

      const predictedAdvancing = resolvePredictedAdvancing(
        row,
        predictedMatchup,
      );
      let officialAdvancing: {
        teamName: string;
        teamLogoUrl: string | null;
        viaPenalties: boolean;
      } | null = null;
      if (
        row.status === "FINISHED" &&
        row.home_score != null &&
        row.away_score != null
      ) {
        const viaPenalties = row.home_score === row.away_score;
        if (row.official_advancing_team_name) {
          officialAdvancing = {
            teamName: row.official_advancing_team_name as string,
            teamLogoUrl:
              (row.official_advancing_team_logo_url as string | null) ?? null,
            viaPenalties,
          };
        } else if (!viaPenalties) {
          const homeWins =
            (row.home_score as number) > (row.away_score as number);
          officialAdvancing = {
            teamName: homeWins
              ? (row.home_team_name as string)
              : (row.away_team_name as string),
            teamLogoUrl: homeWins
              ? ((row.home_team_logo_url as string | null) ?? null)
              : ((row.away_team_logo_url as string | null) ?? null),
            viaPenalties: false,
          };
        }
      }

      const officialMatchup = officialMatchupFromRow({
        official_home_team_id: row.home_team_id,
        official_away_team_id: row.away_team_id,
        official_home_team_name: row.home_team_name as string,
        official_away_team_name: row.away_team_name as string,
        official_home_team_logo_url: row.home_team_logo_url as string | null,
        official_away_team_logo_url: row.away_team_logo_url as string | null,
        home_team_id: row.home_team_id,
        away_team_id: row.away_team_id,
        home_team_name: row.home_team_name as string,
        away_team_name: row.away_team_name as string,
        home_team_logo_url: row.home_team_logo_url as string | null,
        away_team_logo_url: row.away_team_logo_url as string | null,
      });

      const schedule = matchLocalScheduleParts(row);

      return {
        matchId: Number(row.match_id),
        startsAt: row.starts_at,
        calendarDate: schedule.ymd,
        kickoffTimeLocal: schedule.time,
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
        predictedMatchup,
        officialMatchup,
        predictedAdvancing,
        officialAdvancing,
        nextRoundLabel: nextRoundLabelFromKey(row.round_key as string | null),
        points: row.points,
        breakdown: row.breakdown,
      };
    }),
    extras: extrasResult.rows.map((row) =>
      mapExtraScore(
        {
          source_type: row.source_type as string,
          source_id: row.source_id as number,
          points: row.points as number,
          breakdown: row.breakdown as Record<string, unknown>,
          updated_at: row.updated_at as Date,
        },
        bonusExtras,
      ),
    ),
  };
}

export async function isLeaderboardParticipant(
  userId: number,
): Promise<boolean> {
  const result = await pool.query(
    `SELECT 1 FROM users WHERE id = $1 AND role = 'USER' AND is_active = TRUE LIMIT 1`,
    [userId],
  );
  return result.rowCount !== null && result.rowCount > 0;
}
