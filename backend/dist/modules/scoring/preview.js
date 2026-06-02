import { pool } from "../../db/pool.js";
import { loadOfficialScoringRules } from "./loadRules.js";
import { computePredictionPoints } from "./rules.js";
export async function previewMatchPoints(input) {
    const matchResult = await pool.query("SELECT id, stage, round_key, round_label, winner_team_id FROM matches WHERE id = $1", [input.matchId]);
    const match = matchResult.rows[0];
    if (!match)
        throw new Error("Partido no encontrado");
    const rules = await loadOfficialScoringRules();
    let winnerTeamId = match.winner_team_id;
    if (!winnerTeamId && input.realHome !== input.realAway) {
        const full = await pool.query("SELECT home_team_id, away_team_id FROM matches WHERE id = $1", [input.matchId]);
        const row = full.rows[0];
        if (row) {
            winnerTeamId =
                input.realHome > input.realAway
                    ? Number(row.home_team_id)
                    : Number(row.away_team_id);
        }
    }
    return computePredictionPoints({
        predictedHome: input.predictedHome,
        predictedAway: input.predictedAway,
        realHome: input.realHome,
        realAway: input.realAway,
        roundKey: match.round_key,
        stage: match.stage,
        roundLabel: match.round_label,
        predictedAdvancingTeamId: input.predictedAdvancingTeamId ?? null,
        winnerTeamId,
        rules
    });
}
