const ERC721MerkleDropFactoryFeature = artifacts.require("ERC721MerkleDropFactoryFeature");

module.exports = async (deployer) => {
  await deployer.deploy(ERC721MerkleDropFactoryFeature);
};
