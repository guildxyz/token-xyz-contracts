const MerkleVestingFactoryFeature = artifacts.require("MerkleVestingFactoryFeature");

module.exports = async (deployer) => {
  await deployer.deploy(MerkleVestingFactoryFeature);
};
