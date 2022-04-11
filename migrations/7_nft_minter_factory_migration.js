const MerkleNFTMinterFactoryFeature = artifacts.require("MerkleNFTMinterFactoryFeature");

module.exports = async (deployer) => {
  await deployer.deploy(MerkleNFTMinterFactoryFeature);
};
