import { ZodError } from "zod";
import { HttpError } from "../utils/httpError.js";
export function notFound(_req, res) {
    res.status(404).json({ message: "Ruta no encontrada" });
}
export function errorHandler(error, _req, res, _next) {
    if (error instanceof ZodError) {
        res.status(400).json({ message: "Payload inválido", issues: error.issues });
        return;
    }
    if (error instanceof HttpError) {
        res.status(error.statusCode).json({ message: error.message, code: error.code });
        return;
    }
    if (error instanceof Error) {
        res.status(500).json({ message: error.message });
        return;
    }
    res.status(500).json({ message: "Error interno" });
}
