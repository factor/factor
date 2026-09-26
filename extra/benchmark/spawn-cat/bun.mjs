// The node:child_process API used by the original Jarred Sumner gist.
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";

const file = process.argv[2] ?? fileURLToPath(new URL("./spawn-cat.factor", import.meta.url));
async function batch() {
  await Promise.all(Array.from({ length: 100 }, () => new Promise((resolve, reject) => {
    const child = spawn("cat", [file], {
      stdio: ["ignore", "ignore", "ignore"], shell: false,
    });
    child.on("error", reject);
    child.on("exit", code => code === 0 ? resolve() : reject(new Error(`cat exited with ${code}`)));
  })));
}

for (let i = 0; i < 5; i++) await batch();
for (let round = 0; round < 3; round++) {
  const start = performance.now();
  for (let i = 0; i < 100; i++) await batch();
  console.log(JSON.stringify({ round, processes: 10000,
    ms: performance.now() - start, rss: process.memoryUsage.rss() }));
}
