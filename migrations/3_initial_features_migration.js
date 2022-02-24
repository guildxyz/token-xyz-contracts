const SimpleFunctionRegistryFeature = artifacts.require("SimpleFunctionRegistryFeature");
const OwnableFeature = artifacts.require("OwnableFeature");

module.exports = async (deployer) => {
  await deployer.deploy(SimpleFunctionRegistryFeature);
  await deployer.deploy(OwnableFeature);
};
