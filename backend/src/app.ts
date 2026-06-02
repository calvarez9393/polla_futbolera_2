import cors from "cors";
import express from "express";
import helmet from "helmet";
import { pinoHttp } from "pino-http";
import { env } from "./config/env.js";
import { authRouter } from "./modules/auth/routes.js";
import { matchesRouter } from "./modules/matches/routes.js";
import { teamsRouter } from "./modules/teams/routes.js";
import { standingsRouter } from "./modules/standings/routes.js";
import { predictionsRouter } from "./modules/predictions/routes.js";
import { leaderboardRouter } from "./modules/leaderboard/routes.js";
import { adminRouter } from "./modules/admin/routes.js";
import { errorHandler, notFound } from "./middlewares/errorHandler.js";

export const app = express();
app.use(helmet());
app.use(cors({ origin: env.CORS_ORIGIN }));
app.use(express.json());
app.use(pinoHttp());

app.get("/health", (_req, res) => {
  res.json({ ok: true });
});

app.use("/auth", authRouter);
app.use("/matches", matchesRouter);
app.use("/teams", teamsRouter);
app.use("/standings", standingsRouter);
app.use("/predictions", predictionsRouter);
app.use("/leaderboard", leaderboardRouter);
app.use("/admin", adminRouter);

app.use(notFound);
app.use(errorHandler);
