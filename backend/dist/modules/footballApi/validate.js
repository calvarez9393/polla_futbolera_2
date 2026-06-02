import { HttpError } from "../../utils/httpError.js";
export function extractApiFootballErrors(data) {
    if (!data || typeof data !== "object")
        return null;
    const errors = data.errors;
    if (!errors)
        return null;
    if (Array.isArray(errors)) {
        const messages = errors.filter(Boolean).map(String);
        return messages.length ? messages.join(" ") : null;
    }
    if (typeof errors === "object") {
        const messages = Object.values(errors).filter(Boolean);
        return messages.length ? messages.join(" ") : null;
    }
    return String(errors);
}
export function assertApiFootballOk(data, context) {
    const apiError = extractApiFootballErrors(data);
    if (apiError) {
        throw new HttpError(`API-Football (${context}): ${apiError}`, 502, "API_FOOTBALL_PLAN");
    }
}
