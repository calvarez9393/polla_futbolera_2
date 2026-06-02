import { config } from "dotenv";
import { z } from "zod";

config({ path: process.env.NODE_ENV === "test" ? ".env.test" : ".env" });

const schema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  PORT: z.coerce.number().default(4000),
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(16),
  JWT_EXPIRES_IN: z.string().default("7d"),
  CORS_ORIGIN: z
    .string()
    .default("http://localhost:5173,http://localhost:8080")
    .transform((value) =>
      value
        .split(",")
        .map((o) => o.trim())
        .filter(Boolean)
    ),
  API_FOOTBALL_BASE_URL: z.string().url().default("https://v3.football.api-sports.io"),
  API_FOOTBALL_KEY: z.string().default("replace_me"),
  API_FOOTBALL_HOST: z.string().default("v3.football.api-sports.io"),
  API_FOOTBALL_LEAGUE_ID: z.string().default("1"),
  API_FOOTBALL_SEASON: z.string().default("2026"),
  SYNC_CRON: z.string().default("*/5 * * * *"),
  ADMIN_LOGIN: z
    .string()
    .regex(/^\d{4,15}$/, "ADMIN_LOGIN debe ser numérico (4–15 dígitos)")
    .default("1000000001"),
  ADMIN_PASSWORD: z.string().min(6).default("admin1234")
});

const parsed = schema.parse(process.env);

if (parsed.API_FOOTBALL_KEY === "replace_me" || parsed.API_FOOTBALL_KEY.length < 20) {
  console.warn("⚠️  API_FOOTBALL_KEY parece inválida o de ejemplo. La sincronización fallará hasta configurar una key real.");
}

export const env = parsed;
