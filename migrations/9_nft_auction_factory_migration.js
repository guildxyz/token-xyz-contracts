const ERC721AuctionFactoryFeature = artifacts.require("ERC721AuctionFactoryFeature");

/* WETH addresses
  mainnet: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
  ropsten: "0xc778417E063141139Fce010982780140Aa0cD5Ab"
  kovan: "0xd0A1E359811322d97991E03f863a0C30C2cF029C"
  goerli: "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6"
*/
const wethAddress = "...";

module.exports = async (deployer) => {
  await deployer.deploy(ERC721AuctionFactoryFeature, wethAddress);
};
