const ERC721AuctionFactoryFeature = artifacts.require("ERC721AuctionFactoryFeature");

module.exports = async (deployer) => {
  await deployer.deploy(ERC721AuctionFactoryFeature);
};
