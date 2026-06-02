export const DEFAULT_OFFICIAL_RULES = {
    exact_score_points: 5,
    outcome_points: 3,
    draw_points: 3,
    goal_diff_points: 2,
    r8_advance_points: 8,
    r8_exact_points: 5,
    r4_advance_points: 12,
    r4_exact_points: 7,
    sf_advance_points: 18,
    sf_exact_points: 10,
    final_advance_points: 40,
    final_exact_points: 15,
    qualified_team_points: 4,
    champion_points: 40,
    runner_up_points: 20,
    third_place_points: 15,
    top_scorer_points: 25,
    top_assister_points: 20,
    semifinalist_points: 10,
    semifinalist_max_points: 40,
    finalist_points: 20,
    finalist_max_points: 40,
    group_master_bonus: 5,
    expert_day_bonus: 10,
    invicto_bonus: 15
};
export function resolveRoundKey(match) {
    const key = match.round_key?.toUpperCase();
    if (key === "GROUP" || key === "R16" || key === "R8" || key === "R4" || key === "SF" || key === "F" || key === "TP3") {
        return key;
    }
    const label = (match.round_label ?? "").toLowerCase();
    if (label.includes("dieciseis") || label.includes("16"))
        return "R16";
    if (label.includes("octavo"))
        return "R8";
    if (label.includes("cuarto"))
        return "R4";
    if (label.includes("semifinal"))
        return "SF";
    if (label.includes("tercer"))
        return "TP3";
    if (label.includes("final") && !label.includes("semi"))
        return "F";
    return match.stage === "GROUP" ? "GROUP" : "R16";
}
export function isPhase1Round(roundKey) {
    return roundKey === "GROUP" || roundKey === "R16";
}
function knockoutRoundPoints(roundKey, rules) {
    switch (roundKey) {
        case "R8":
            return { advance: rules.r8_advance_points, exact: rules.r8_exact_points };
        case "R4":
            return { advance: rules.r4_advance_points, exact: rules.r4_exact_points };
        case "SF":
            return { advance: rules.sf_advance_points, exact: rules.sf_exact_points };
        case "F":
        case "TP3":
            return { advance: rules.final_advance_points, exact: rules.final_exact_points };
        default:
            return { advance: 0, exact: 0 };
    }
}
export function getKnockoutRoundPoints(roundKey, rules) {
    return knockoutRoundPoints(roundKey, rules);
}
