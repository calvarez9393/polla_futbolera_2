import { Router } from "express";
import { z } from "zod";
import { requireAdmin, requireAuth } from "../../middlewares/auth.js";
import {
  calculateBonusScores,
  getOfficialBonusResults,
  setOfficialBonusResults,
  type OfficialBonusResults
} from "../scoring/bonuses.js";
import {
  calculateQualifierScores,
  getOfficialQualifiedTeams,
  setOfficialQualifiedTeams
} from "../scoring/qualifiers.js";
import { importWorldCup2026Knockout } from "../import/worldCup2026Knockout.js";
import {
  getOfficialStandingsByGroup,
  syncAllUsersQualifierPredictions,
  syncOfficialQualifiersFromResults
} from "../qualifiers/fromPredictions.js";
import { getActiveTournamentId } from "../settings/service.js";
import { pool } from "../../db/pool.js";
import {
  calculateExpertDayBonuses,
  calculateInvictoAndGroupMasterBonuses
} from "../scoring/phase1Bonuses.js";
import {
  applyR16PairingsToMatches,
  autoFillOfficialR16FromResults,
  getOfficialR16Bracket,
  listQualifiedTeamsForR16
} from "../bracket/r16Service.js";

const officialQualifiersSchema = z.object({
  teamIds: z.array(z.coerce.number().int().positive()).length(24)
});

const r16PairingSchema = z.object({
  pairings: z.array(
    z.object({
      matchId: z.coerce.number().int().positive(),
      homeTeamId: z.coerce.number().int().positive(),
      awayTeamId: z.coerce.number().int().positive()
    })
  )
});

const officialBonusesSchema = z.object({
  championTeamId: z.coerce.number().int().positive().nullable().optional(),
  runnerUpTeamId: z.coerce.number().int().positive().nullable().optional(),
  thirdPlaceTeamId: z.coerce.number().int().positive().nullable().optional(),
  semifinalistTeamIds: z.array(z.coerce.number().int().positive()).max(4).optional(),
  finalistTeamIds: z.array(z.coerce.number().int().positive()).max(2).optional(),
  topScorer: z.string().max(120).nullable().optional(),
  topAssister: z.string().max(120).nullable().optional()
});

export const adminScoringRouter = Router();
adminScoringRouter.use(requireAuth, requireAdmin);

adminScoringRouter.post("/matches/import-worldcup-2026-knockout", async (_req, res, next) => {
  try {
    const result = await importWorldCup2026Knockout();
    res.json(result);
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.get("/official/qualifiers", async (_req, res, next) => {
  try {
    res.json({ teamIds: await getOfficialQualifiedTeams() });
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.put("/official/qualifiers", async (req, res, next) => {
  try {
    const { teamIds } = officialQualifiersSchema.parse(req.body);
    await setOfficialQualifiedTeams(teamIds);
    res.json({ teamIds });
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.post("/scoring/calculate-qualifiers", async (_req, res, next) => {
  try {
    const result = await calculateQualifierScores();
    res.json(result);
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.get("/official/bonuses", async (_req, res, next) => {
  try {
    res.json(await getOfficialBonusResults());
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.put("/official/bonuses", async (req, res, next) => {
  try {
    const input = officialBonusesSchema.parse(req.body);
    await setOfficialBonusResults(input as OfficialBonusResults);
    res.json({ ok: true });
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.post("/scoring/calculate-bonuses", async (_req, res, next) => {
  try {
    const result = await calculateBonusScores();
    res.json(result);
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.post("/scoring/calculate-expert-day-bonuses", async (_req, res, next) => {
  try {
    const result = await calculateExpertDayBonuses();
    res.json(result);
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.post("/scoring/calculate-phase1-bonuses", async (_req, res, next) => {
  try {
    const result = await calculateInvictoAndGroupMasterBonuses();
    res.json(result);
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.post("/scoring/sync-qualifiers-from-predictions", async (_req, res, next) => {
  try {
    const result = await syncAllUsersQualifierPredictions();
    res.json(result);
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.post("/scoring/sync-official-qualifiers-from-results", async (_req, res, next) => {
  try {
    const teamIds = await syncOfficialQualifiersFromResults();
    res.json({ teamIds, count: teamIds.length });
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.get("/official/standings", async (_req, res, next) => {
  try {
    res.json({ groups: await getOfficialStandingsByGroup() });
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.get("/official/r16-bracket", async (_req, res, next) => {
  try {
    const bracket = await getOfficialR16Bracket();
    const teams = await listQualifiedTeamsForR16();
    res.json({ ...bracket, teams });
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.put("/official/r16-bracket", async (req, res, next) => {
  try {
    const { pairings } = r16PairingSchema.parse(req.body);
    await applyR16PairingsToMatches(pairings);
    res.json(await getOfficialR16Bracket());
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.post("/official/r16-bracket/auto-from-results", async (_req, res, next) => {
  try {
    const result = await autoFillOfficialR16FromResults();
    const bracket = await getOfficialR16Bracket();
    res.json({ ...result, ...bracket });
  } catch (error) {
    next(error);
  }
});

adminScoringRouter.get("/official/context", async (_req, res, next) => {
  try {
    const tournamentId = await getActiveTournamentId();
    const teamIds = await getOfficialQualifiedTeams();
    const bonuses = await getOfficialBonusResults();

    const teams = tournamentId
      ? (
          await pool.query(
            `SELECT t.id, t.name, t.short_name, t.logo_url, g.id AS group_id, g.name AS group_name
            FROM teams t
            JOIN standings s ON s.team_id = t.id AND s.tournament_id = $1
            JOIN groups g ON g.id = s.group_id
            ORDER BY g.name, t.name`,
            [tournamentId]
          )
        ).rows.map((r) => ({
          id: Number(r.id),
          name: r.name,
          shortName: r.short_name,
          logoUrl: r.logo_url,
          groupId: Number(r.group_id),
          groupName: r.group_name
        }))
      : [];

    const byGroup = new Map<string, typeof teams>();
    for (const t of teams) {
      const key = t.groupName;
      if (!byGroup.has(key)) byGroup.set(key, []);
      byGroup.get(key)!.push(t);
    }

    res.json({
      qualifiedTeamIds: teamIds,
      bonuses,
      groups: [...byGroup.entries()].map(([name, groupTeams]) => ({
        name,
        teams: groupTeams
      }))
    });
  } catch (error) {
    next(error);
  }
});
