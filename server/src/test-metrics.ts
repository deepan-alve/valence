import { githubPlugin } from "./plugins/github.js";
import { chessComPlugin } from "./plugins/chess-com.js";
import { duolingoPlugin } from "./plugins/duolingo.js";

async function main() {
  const gh = await githubPlugin.fetchTodayStatus({ username: "torvalds" });
  console.log("GitHub:", JSON.stringify(gh));

  const chess = await chessComPlugin.fetchTodayStatus({ username: "deepanalve" });
  console.log("Chess:", JSON.stringify(chess));

  const duo = await duolingoPlugin.fetchTodayStatus({ username: "chanderrrr" });
  console.log("Duolingo:", JSON.stringify(duo));

  process.exit(0);
}
main();
