const ERC721CurveFactoryFeature = artifacts.require("ERC721CurveFactoryFeature");

module.exports = async (deployer) => {
  await deployer.deploy(ERC721CurveFactoryFeature);
};
