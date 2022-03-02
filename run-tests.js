const { exec, spawn } = require("child_process");

exec(
  'npx ganache --account "0xd28366d7da2f21508189a1f00a3cd75c3e9e9c2d66cd0490de4668fa7f66052c, 100000000000000000000" --account "0x7aa07a66aa009a228e0d7d8f48fbc6f86a26dfb7c8f37605365dfc0c681c8e94, 100000000000000000000" --account "0x0de14d5b5ddc433fcc365fe6ee935783c9eef9c127ef5d81021085eb4175e602, 100000000000000000000"',
  { stdio: "ignore" }
);

const truffleArgs = ["truffle", "test", "--migrations_directory", "test"];
if (process.argv[2] !== undefined) truffleArgs.push(process.argv[2]);
const truffle = spawn("npx", truffleArgs, { stdio: "inherit" });

truffle.on("exit", () => process.exit());
