const MerkleDistributorFactoryFeature = artifacts.require("MerkleDistributorFactoryFeature");

module.exports = async (deployer) => {
  await deployer.deploy(MerkleDistributorFactoryFeature);
};
