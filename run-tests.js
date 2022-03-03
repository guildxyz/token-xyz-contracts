const { exec, spawn } = require("child_process");

exec('npx ganache --mnemonic "horn horn horn horn horn horn horn horn horn horn horn horn"', { stdio: "ignore" });

const truffleArgs = ["truffle", "test", "--migrations_directory", "test"];
if (process.argv[2] !== undefined) truffleArgs.push(process.argv[2]);
const truffle = spawn("npx", truffleArgs, { stdio: "inherit" });

truffle.on("exit", () => process.exit());
