const { spawn } = require("child_process");

spawn("ganache", ["--mnemonic", "horn horn horn horn horn horn horn horn horn horn horn horn"]);

const truffleArgs = ["test", "--migrations_directory", "test"];
if (process.argv[2] !== undefined) truffleArgs.push(process.argv[2]);
setTimeout(() => spawn("truffle", truffleArgs, { stdio: "inherit" }).on("exit", () => process.exit()), 4200);
