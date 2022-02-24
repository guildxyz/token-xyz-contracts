const bootstrapper = "0x..."; // The address who will initialize the contracts. Ideally it's the future owner address.

const InitialMigration = artifacts.require("InitialMigration");
const TokenXyz = artifacts.require("TokenXyz");

module.exports = async (deployer) => {
  await deployer.deploy(InitialMigration, bootstrapper);
  await deployer.deploy(TokenXyz, InitialMigration.address);
};
