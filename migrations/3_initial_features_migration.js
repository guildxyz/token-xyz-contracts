const SimpleFunctionRegistryFeature = artifacts.require("SimpleFunctionRegistryFeature");
const OwnableFeature = artifacts.require("OwnableFeature");
const MulticallFeature = artifacts.require("MulticallFeature");

module.exports = async (deployer) => {
  await deployer.deploy(SimpleFunctionRegistryFeature);
  await deployer.deploy(OwnableFeature);
  await deployer.deploy(MulticallFeature);
};
