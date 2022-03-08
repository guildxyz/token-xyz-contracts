const initializeCaller = "0x..."; // The address who will initialize the contracts. Ideally it's the future owner address.

// Uncomment the migration contract you want to use
// const TokenXyzMigration = artifacts.require("InitialMigration");
const TokenXyzMigration = artifacts.require("FullMigration");
const TokenXyz = artifacts.require("TokenXyz");

module.exports = async (deployer) => {
  await deployer.deploy(TokenXyzMigration, initializeCaller);
  const migrator = await TokenXyzMigration.deployed();
  await deployer.deploy(TokenXyz, await migrator.getBootstrapper());
};
