import type { NextFunction, Request, Response } from "express";
import { ZodError } from "zod";
import { HttpError } from "../utils/httpError.js";

export function notFound(_req: Request, res: Response): void {
  res.status(404).json({ message: "Ruta no encontrada" });
}

export function errorHandler(error: unknown, _req: Request, res: Response, _next: NextFunction): void {
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
