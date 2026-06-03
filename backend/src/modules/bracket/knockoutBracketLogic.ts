import { WC2026_KNOCKOUT_FIXTURES } from "./wc2026KnockoutFixtures.js";

export type FeedType = "winner" | "loser";

export interface SlotFeed {
  type: FeedType;
  matchNum: number;
}

export interface KnockoutMatchRow {
  id: number;
  external_id: string;
  status: string;
  home_team_id: number;
  away_team_id: number;
  home_score: number | null;
  away_score: number | null;
  winner_team_id: number | null;
}

export interface UserPredictionRow {
  predicted_home_score: number | null;
  predicted_away_score: number | null;
  predicted_advancing_team_id: number | null;
}

export const KNOCKOUT_SLOT_FEEDS: Record<number, { home?: SlotFeed; away?: SlotFeed }> =
  buildSlotFeeds();

function buildSlotFeeds(): Record<number, { home?: SlotFeed; away?: SlotFeed }> {
  const feeds: Record<number, { home?: SlotFeed; away?: SlotFeed }> = {};

  for (const fx of WC2026_KNOCKOUT_FIXTURES) {
    if (fx.roundKey === "R16") continue;
    const home = parseSlotFeed(fx.homeSlot);
    const away = parseSlotFeed(fx.awaySlot);
    if (home || away) feeds[fx.num] = { home, away };
  }
  return feeds;
}

export function parseSlotFeed(slot: string): SlotFeed | undefined {
  const s = slot.trim();
  let m = s.match(/^Ganador partido (\d+)$/i);
  if (m) return { type: "winner", matchNum: Number(m[1]) };
  m = s.match(/^Ganador octavos (\d+)$/i);
  if (m) return { type: "winner", matchNum: Number(m[1]) };
  m = s.match(/^Ganador cuartos (\d+)$/i);
  if (m) return { type: "winner", matchNum: Number(m[1]) };
  m = s.match(/^Ganador semifinal (\d+)$/i);
  if (m) return { type: "winner", matchNum: 100 + Number(m[1]) };
  m = s.match(/^Perdedor semifinal (\d+)$/i);
  if (m) return { type: "loser", matchNum: 100 + Number(m[1]) };
  return undefined;
}

export const KNOCKOUT_MATCH_ORDER = WC2026_KNOCKOUT_FIXTURES.map((f) => f.num);

export function knockoutExternalNum(externalId: string): number | null {
  const m = externalId.match(/wc2026-ko-(\d+)/i);
  return m ? Number(m[1]) : null;
}

export function matchOutcome(
  row: KnockoutMatchRow,
  prediction: UserPredictionRow | null | undefined,
  resolvedHomeId: number,
  resolvedAwayId: number,
  tbdId: number
): { winnerId: number | null; loserId: number | null } {
  const home = Number(resolvedHomeId);
  const away = Number(resolvedAwayId);
  if (home === tbdId || away === tbdId) {
    return { winnerId: null, loserId: null };
  }

  if (row.status === "FINISHED") {
    if (row.winner_team_id && Number(row.winner_team_id) !== tbdId) {
      const winnerId = Number(row.winner_team_id);
      const loserId = winnerId === home ? away : home;
      return { winnerId, loserId };
    }
    if (row.home_score != null && row.away_score != null && row.home_score !== row.away_score) {
      const winnerId = row.home_score > row.away_score ? home : away;
      const loserId = winnerId === home ? away : home;
      return { winnerId, loserId };
    }
    return { winnerId: null, loserId: null };
  }

  const advRaw = prediction?.predicted_advancing_team_id;
  const adv = advRaw != null ? Number(advRaw) : null;
  if (adv != null && !Number.isNaN(adv) && adv !== tbdId && (adv === home || adv === away)) {
    return { winnerId: adv, loserId: adv === home ? away : home };
  }

  const ph = prediction?.predicted_home_score;
  const pa = prediction?.predicted_away_score;
  if (ph != null && pa != null && ph !== pa) {
    const winnerId = ph > pa ? home : away;
    const loserId = winnerId === home ? away : home;
    return { winnerId, loserId };
  }

  return { winnerId: null, loserId: null };
}

function teamFromFeed(
  feed: SlotFeed,
  outcome: { winnerId: number | null; loserId: number | null }
): number | null {
  return feed.type === "winner" ? outcome.winnerId : outcome.loserId;
}

export function resolveKnockoutBracketTeams(
  rows: KnockoutMatchRow[],
  predictionsByMatchId: Map<number, UserPredictionRow>,
  tbdId: number
): Map<number, { homeTeamId: number; awayTeamId: number }> {
  const byNum = new Map<number, KnockoutMatchRow>();
  for (const row of rows) {
    const num = knockoutExternalNum(row.external_id);
    if (num != null) byNum.set(num, row);
  }

  const resolved = new Map<number, { homeTeamId: number; awayTeamId: number }>();

  for (const num of KNOCKOUT_MATCH_ORDER) {
    const row = byNum.get(num);
    if (!row) continue;

    const feeds = KNOCKOUT_SLOT_FEEDS[num];
    let homeTeamId = row.home_team_id;
    let awayTeamId = row.away_team_id;

    if (feeds?.home) {
      const feeder = byNum.get(feeds.home.matchNum);
      if (feeder) {
        const feederResolved = resolved.get(feeds.home.matchNum);
        const feederHome = feederResolved?.homeTeamId ?? feeder.home_team_id;
        const feederAway = feederResolved?.awayTeamId ?? feeder.away_team_id;
        const outcome = matchOutcome(
          feeder,
          predictionsByMatchId.get(feeder.id),
          feederHome,
          feederAway,
          tbdId
        );
        const picked = teamFromFeed(feeds.home, outcome);
        if (picked && picked !== tbdId) homeTeamId = picked;
      }
    }

    if (feeds?.away) {
      const feeder = byNum.get(feeds.away.matchNum);
      if (feeder) {
        const feederResolved = resolved.get(feeds.away.matchNum);
        const feederHome = feederResolved?.homeTeamId ?? feeder.home_team_id;
        const feederAway = feederResolved?.awayTeamId ?? feeder.away_team_id;
        const outcome = matchOutcome(
          feeder,
          predictionsByMatchId.get(feeder.id),
          feederHome,
          feederAway,
          tbdId
        );
        const picked = teamFromFeed(feeds.away, outcome);
        if (picked && picked !== tbdId) awayTeamId = picked;
      }
    }

    resolved.set(num, { homeTeamId: Number(homeTeamId), awayTeamId: Number(awayTeamId) });
  }

  return resolved;
}

export function feedsReferencing(feederNum: number): Array<{
  targetNum: number;
  side: "home" | "away";
  feed: SlotFeed;
}> {
  const refs: Array<{ targetNum: number; side: "home" | "away"; feed: SlotFeed }> = [];
  for (const [targetNum, slots] of Object.entries(KNOCKOUT_SLOT_FEEDS)) {
    const n = Number(targetNum);
    if (slots.home?.matchNum === feederNum) refs.push({ targetNum: n, side: "home", feed: slots.home });
    if (slots.away?.matchNum === feederNum) refs.push({ targetNum: n, side: "away", feed: slots.away });
  }
  return refs;
}
