const TokenFactoryFeature = artifacts.require("TokenFactoryFeature");

module.exports = async (deployer) => {
  await deployer.deploy(TokenFactoryFeature);
};
