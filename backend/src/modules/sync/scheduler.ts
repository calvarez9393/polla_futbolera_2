import cron from "node-cron";
import { env } from "../../config/env.js";
import { getSetting } from "../settings/service.js";
import { runSync } from "./service.js";

export function startScheduler(): void {
  cron.schedule(env.SYNC_CRON, async () => {
    try {
      const source = await getSetting("data_source", "manual");
      if (source !== "api") return;
      await runSync("cron");
    } catch (error) {
      console.error("Sync cron error:", error);
    }
  });
}
