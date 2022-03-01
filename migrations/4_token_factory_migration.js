const TokenFactoryFeature = artifacts.require("TokenFactoryFeature");
const TokenWithRolesFactoryFeature = artifacts.require("TokenWithRolesFactoryFeature");

module.exports = async (deployer) => {
  await deployer.deploy(TokenFactoryFeature);
  await deployer.deploy(TokenWithRolesFactoryFeature);
};
