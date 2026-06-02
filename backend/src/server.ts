import { app } from "./app.js";
import { env } from "./config/env.js";
import { startScheduler } from "./modules/sync/scheduler.js";

app.listen(env.PORT, () => {
  console.log(`Backend listening on ${env.PORT}`);
});

startScheduler();
