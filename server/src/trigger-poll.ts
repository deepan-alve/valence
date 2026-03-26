import { pluginPollerQueue } from "./jobs/queues.js";

async function main() {
  await pluginPollerQueue.add("manual-poll", {});
  console.log("Job added to plugin-poller queue");
  // Give it a moment to flush
  setTimeout(() => process.exit(0), 500);
}
main();
