import { duolingoPlugin } from "./plugins/duolingo.js";

async function main() {
  console.log("Testing authenticate...");
  const auth = await duolingoPlugin.authenticate({ username: "chanderrrr" });
  console.log("Auth:", auth);

  console.log("\nTesting fetchTodayStatus...");
  const status = await duolingoPlugin.fetchTodayStatus({ username: "chanderrrr" });
  console.log("Status:", JSON.stringify(status, null, 2));

  process.exit(0);
}
main();
