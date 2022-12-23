const { exec, spawn } = require("child_process");

spawn("ganache", ["--mnemonic", "horn horn horn horn horn horn horn horn horn horn horn horn", "--detach"]).stdout.on(
  "data",
  (ganacheId) => {
    const truffleArgs = ["test", "--migrations_directory", "test"];
    if (process.argv[2]) truffleArgs.push(process.argv[2]);

    spawn("truffle", truffleArgs, { stdio: "inherit" }).on("exit", () => exec(`ganache instances stop ${ganacheId}`));
  }
);
