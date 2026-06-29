import { pool } from "../../db/pool.js";
import {
  KNOCKOUT_MATCH_ORDER,
  KNOCKOUT_SLOT_FEEDS,
  knockoutExternalNum,
  matchOutcomeOfficial,
  type KnockoutMatchRow
} from "./knockoutBracketLogic.js";
import {
  getTbdTeamId,
  loadKnockoutRowsForTournament,
  loadTeamNames
} from "./knockoutAdvancement.js";
import { WC2026_KNOCKOUT_FIXTURES } from "./wc2026KnockoutFixtures.js";

export interface KnockoutSlotChange {
  num: number;
  roundKey: string;
  roundLabel: string;
  fromHome: string | null;
  toHome: string | null;
  fromAway: string | null;
  toAway: string | null;
}

export interface KnockoutWinnerChange {
  num: number;
  roundKey: string;
  roundLabel: string;
  fromWinner: string | null;
  toWinner: string | null;
}

export interface KnockoutReviewItem {
  num: number;
  roundKey: string;
  roundLabel: string;
  reason: string;
}

export interface KnockoutRepairReport {
  applied: boolean;
  totalChanges: number;
  changedSlots: KnockoutSlotChange[];
  changedWinners: KnockoutWinnerChange[];
  needsReview: KnockoutReviewItem[];
  rescoredMatches: number[];
}

const ROUND_META = new Map<number, { roundKey: string; roundLabel: string }>(
  WC2026_KNOCKOUT_FIXTURES.map((fx) => [fx.num, { roundKey: fx.roundKey, roundLabel: fx.roundLabel }])
);

function metaFor(num: number): { roundKey: string; roundLabel: string } {
  return ROUND_META.get(num) ?? { roundKey: "", roundLabel: `Partido ${num}` };
}

/**
 * Reconstruye el cuadro oficial desde los resultados reales, ronda por ronda, y deja cada cruce
 * con los equipos que de verdad clasificaron a él. Corrige el bug de que, al corregir un partido
 * anterior, los siguientes seguían mostrando el equipo viejo: aquí el ganador de cada llave se
 * recalcula contra sus participantes ACTUALES (no se confía en un winner_team_id "huérfano").
 *
 * No es destructivo: conserva los marcadores cargados aunque el cruce haya cambiado de equipos;
 * solo recoloca equipos, normaliza el ganador a un participante válido y vuelve a puntuar los
 * partidos finalizados afectados. Cuando un cruce queda sin definir o un empate pierde su ganador
 * en penales, se reporta en `needsReview` para que el admin lo revise a mano.
 */
export async function repairOfficialKnockoutBracket(
  tournamentId: number,
  options: { apply?: boolean } = {}
): Promise<KnockoutRepairReport> {
  const apply = options.apply ?? false;
  const empty: KnockoutRepairReport = {
    applied: apply,
    totalChanges: 0,
    changedSlots: [],
    changedWinners: [],
    needsReview: [],
    rescoredMatches: []
  };

  const rows = await loadKnockoutRowsForTournament(tournamentId);
  if (rows.length === 0) return empty;

  const tbdId = await getTbdTeamId();
  const byNum = new Map<number, KnockoutMatchRow>();
  for (const row of rows) {
    const num = knockoutExternalNum(row.external_id);
    if (num != null) byNum.set(num, row);
  }

  // 1) Resolución determinista del cuadro: en orden de ronda, cada llave toma sus equipos de los
  //    ganadores/perdedores ya resueltos aguas arriba; si la fuente no está decidida, queda «Por definir».
  const resolvedTeams = new Map<number, { home: number; away: number }>();
  const winners = new Map<number, number | null>();
  const losers = new Map<number, number | null>();
  const desiredWinner = new Map<number, number | null>();

  for (const num of KNOCKOUT_MATCH_ORDER) {
    const row = byNum.get(num);
    if (!row) continue;
    const feeds = KNOCKOUT_SLOT_FEEDS[num];

    let home = Number(row.home_team_id);
    let away = Number(row.away_team_id);

    if (feeds?.home) {
      const picked =
        feeds.home.type === "winner" ? winners.get(feeds.home.matchNum) : losers.get(feeds.home.matchNum);
      home = picked && picked !== tbdId ? picked : tbdId;
    }
    if (feeds?.away) {
      const picked =
        feeds.away.type === "winner" ? winners.get(feeds.away.matchNum) : losers.get(feeds.away.matchNum);
      away = picked && picked !== tbdId ? picked : tbdId;
    }

    resolvedTeams.set(num, { home, away });

    const outcome = matchOutcomeOfficial(row, home, away, tbdId);
    winners.set(num, outcome.winnerId);
    losers.set(num, outcome.loserId);
    desiredWinner.set(num, outcome.winnerId);
  }

  // 2) Nombres para el reporte.
  const ids = new Set<number>();
  for (const row of rows) {
    ids.add(Number(row.home_team_id));
    ids.add(Number(row.away_team_id));
    if (row.winner_team_id) ids.add(Number(row.winner_team_id));
  }
  for (const v of resolvedTeams.values()) {
    ids.add(v.home);
    ids.add(v.away);
  }
  for (const w of desiredWinner.values()) if (w) ids.add(w);
  const names = await loadTeamNames([...ids]);
  const nameOf = (id: number | null): string | null => {
    if (id == null) return null;
    if (id === tbdId) return "Por definir";
    return names.get(id)?.name ?? `Equipo ${id}`;
  };

  // 3) Diferencias y aplicación.
  const report: KnockoutRepairReport = {
    applied: apply,
    totalChanges: 0,
    changedSlots: [],
    changedWinners: [],
    needsReview: [],
    rescoredMatches: []
  };

  for (const num of KNOCKOUT_MATCH_ORDER) {
    const row = byNum.get(num);
    if (!row) continue;
    const meta = metaFor(num);
    const want = resolvedTeams.get(num)!;
    const wantWinner = desiredWinner.get(num) ?? null;
    const storedHome = Number(row.home_team_id);
    const storedAway = Number(row.away_team_id);
    const storedWinner = row.winner_team_id != null ? Number(row.winner_team_id) : null;

    if (row.status === "FINISHED" && (want.home === tbdId || want.away === tbdId)) {
      report.needsReview.push({
        ...meta,
        num,
        reason: "Figura jugado pero su cruce quedó sin definir tras corregir un partido anterior."
      });
    } else if (row.status === "FINISHED" && wantWinner == null) {
      report.needsReview.push({
        ...meta,
        num,
        reason: "Empate sin ganador en penales válido tras recolocar equipos; define quién pasa."
      });
    }

    const teamsChanged = storedHome !== want.home || storedAway !== want.away;
    const winnerChanged = storedWinner !== wantWinner;
    if (!teamsChanged && !winnerChanged) continue;

    if (teamsChanged) {
      report.changedSlots.push({
        ...meta,
        num,
        fromHome: nameOf(storedHome),
        toHome: nameOf(want.home),
        fromAway: nameOf(storedAway),
        toAway: nameOf(want.away)
      });
    }
    if (winnerChanged) {
      report.changedWinners.push({
        ...meta,
        num,
        fromWinner: nameOf(storedWinner),
        toWinner: nameOf(wantWinner)
      });
    }

    if (apply) {
      await pool.query(
        `UPDATE matches SET home_team_id = $1, away_team_id = $2, winner_team_id = $3, updated_at = NOW()
        WHERE id = $4`,
        [want.home, want.away, wantWinner, row.id]
      );
      if (row.status === "FINISHED") {
        const { calculateMatchScores } = await import("../scoring/service.js");
        await calculateMatchScores(row.id);
        report.rescoredMatches.push(num);
      }
    }
  }

  report.totalChanges = report.changedSlots.length + report.changedWinners.length;
  return report;
}
