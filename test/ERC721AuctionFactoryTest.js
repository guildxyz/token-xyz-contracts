const { utils } = require("ethers");
const { expectEvent, time } = require("@openzeppelin/test-helpers");
const expect = require("chai").expect;

const InitialMigration = artifacts.require("InitialMigration");
const TokenXyz = artifacts.require("TokenXyz");
const ITokenXyz = artifacts.require("ITokenXyz");
const SimpleFunctionRegistryFeature = artifacts.require("SimpleFunctionRegistryFeature");
const OwnableFeature = artifacts.require("OwnableFeature");
const ERC721AuctionFactoryFeature = artifacts.require("ERC721AuctionFactoryFeature");
const ERC721Auction = artifacts.require("ERC721Auction");

const nftMetadata0 = {
  name: "NFTXYZ",
  symbol: "XYZ",
  ipfsHash: "QmPaZD7i8TpLEeGjHtGoXe4mPKbRNNt8YTHH5nrKoqz9wJ",
  maxSupply: "42"
};
const nftMetadata1 = {
  name: "SOMENFTXYZ",
  symbol: "SNFT",
  ipfsHash: "QmPaZD7i8TpLEeGjHtGoXe4mPKbRNNt8YTHH5nrKoqz9wJ",
  maxSupply: "36"
};
const auctionConfig = {
  startingPrice: "1",
  auctionDuration: "86400",
  timeBuffer: "300",
  minimumPercentageIncreasex100: "500"
};

contract("ERC721AuctionFactory", function (accounts) {
  const [wallet0, wallet1] = accounts;
  let tokenXyz;
  let erc721AuctionFactory;

  before("deploy contracts", async function () {
    const initialMigration = await InitialMigration.new(wallet0);
    tokenXyz = await TokenXyz.new(initialMigration.address);
    tokenXyz = await ITokenXyz.at(tokenXyz.address);
    const functionRegistry = await SimpleFunctionRegistryFeature.new();
    const ownable = await OwnableFeature.new();
    const features = {
      registry: functionRegistry.address,
      ownable: ownable.address
    };
    await initialMigration.initializeTokenXyz(wallet0, tokenXyz.address, features);
    erc721AuctionFactory = await ERC721AuctionFactoryFeature.new();
    const migrateInterface = new utils.Interface(["function migrate()"]);
    await tokenXyz.migrate(erc721AuctionFactory.address, migrateInterface.encodeFunctionData("migrate()"), wallet0);
  });

  it("saves deployed tokens' addresses", async function () {
    await tokenXyz.createNFTAuction("Alice", nftMetadata0, auctionConfig, 0, wallet0);
    await tokenXyz.createNFTAuction("Alice", nftMetadata1, auctionConfig, 0, wallet0, { from: wallet1 });
    await tokenXyz.createNFTAuction("Bob", nftMetadata0, auctionConfig, 0, wallet1, { from: wallet1 });
    const nftAddressesAlice = await tokenXyz.getDeployedNFTAuctions("Alice");
    const nftAddressesBob = await tokenXyz.getDeployedNFTAuctions("Bob");
    const factoryVersion = await erc721AuctionFactory.FEATURE_VERSION();
    expect(nftAddressesAlice.length).to.eq(2);
    expect(nftAddressesBob.length).to.eq(1);
    expect(nftAddressesAlice[0].factoryVersion).to.bignumber.eq(factoryVersion);
    expect(nftAddressesAlice[1].factoryVersion).to.bignumber.eq(factoryVersion);
    expect(nftAddressesBob[0].factoryVersion).to.bignumber.eq(factoryVersion);
  });

  it("creates nft contracts with the right parameters", async function () {
    const timestamp = await time.latest();
    const nftAddressesAlice = await tokenXyz.getDeployedNFTAuctions("Alice");
    const nftAddressesBob = await tokenXyz.getDeployedNFTAuctions("Bob");
    const nftAlice0 = await ERC721Auction.at(nftAddressesAlice[0].contractAddress);
    const nftAlice1 = await ERC721Auction.at(nftAddressesAlice[1].contractAddress);
    const nftBob0 = await ERC721Auction.at(nftAddressesBob[0].contractAddress);
    const nftAlice0Config = await nftAlice0.getAuctionConfig();
    const nftAlice1Config = await nftAlice1.getAuctionConfig();
    const nftBob0Config = await nftBob0.getAuctionConfig();
    const nftAlice0State = await nftAlice0.getAuctionState();
    const nftAlice1State = await nftAlice1.getAuctionState();
    const nftBob0State = await nftBob0.getAuctionState();
    expect(await nftAlice0.name()).to.eq(nftMetadata0.name);
    expect(await nftAlice1.name()).to.eq(nftMetadata1.name);
    expect(await nftBob0.name()).to.eq(nftMetadata0.name);
    expect(await nftAlice0.symbol()).to.eq(nftMetadata0.symbol);
    expect(await nftAlice1.symbol()).to.eq(nftMetadata1.symbol);
    expect(await nftBob0.symbol()).to.eq(nftMetadata0.symbol);
    expect(await nftAlice0.maxSupply()).to.bignumber.eq(nftMetadata0.maxSupply);
    expect(await nftAlice1.maxSupply()).to.bignumber.eq(nftMetadata1.maxSupply);
    expect(await nftBob0.maxSupply()).to.bignumber.eq(nftMetadata0.maxSupply);
    expect(nftAlice0Config.startingPrice).to.bignumber.eq(auctionConfig.startingPrice);
    expect(nftAlice1Config.startingPrice).to.bignumber.eq(auctionConfig.startingPrice);
    expect(nftBob0Config.startingPrice).to.bignumber.eq(auctionConfig.startingPrice);
    expect(nftAlice0Config.auctionDuration).to.bignumber.eq(auctionConfig.auctionDuration);
    expect(nftAlice1Config.auctionDuration).to.bignumber.eq(auctionConfig.auctionDuration);
    expect(nftBob0Config.auctionDuration).to.bignumber.eq(auctionConfig.auctionDuration);
    expect(nftAlice0Config.timeBuffer).to.bignumber.eq(auctionConfig.timeBuffer);
    expect(nftAlice1Config.timeBuffer).to.bignumber.eq(auctionConfig.timeBuffer);
    expect(nftBob0Config.timeBuffer).to.bignumber.eq(auctionConfig.timeBuffer);
    expect(nftAlice0Config.minimumPercentageIncreasex100).to.bignumber.eq(auctionConfig.minimumPercentageIncreasex100);
    expect(nftAlice1Config.minimumPercentageIncreasex100).to.bignumber.eq(auctionConfig.minimumPercentageIncreasex100);
    expect(nftBob0Config.minimumPercentageIncreasex100).to.bignumber.eq(auctionConfig.minimumPercentageIncreasex100);
    expect(nftAlice0State.startTime).to.bignumber.closeTo(timestamp, "60");
    expect(nftAlice1State.startTime).to.bignumber.closeTo(timestamp, "60");
    expect(nftBob0State.startTime).to.bignumber.closeTo(timestamp, "60");
    expect(await nftAlice0.owner()).to.eq(wallet0);
    expect(await nftAlice1.owner()).to.eq(wallet0);
    expect(await nftBob0.owner()).to.eq(wallet1);
  });

  it("emits ERC721AuctionDeployed event", async function () {
    const res0 = await tokenXyz.createNFTAuction("Alice", nftMetadata0, auctionConfig, 0, wallet0);
    const res1 = await tokenXyz.createNFTAuction("Bob", nftMetadata0, auctionConfig, 0, wallet1, { from: wallet1 });
    const nftAddressesAlice = await tokenXyz.getDeployedNFTAuctions("Alice");
    const nftAddressesBob = await tokenXyz.getDeployedNFTAuctions("Bob");
    const factoryVersion = await erc721AuctionFactory.FEATURE_VERSION();
    await expectEvent(res0.receipt, "ERC721AuctionDeployed", {
      deployer: wallet0,
      urlName: "Alice",
      instance: nftAddressesAlice[nftAddressesAlice.length - 1].contractAddress,
      factoryVersion: factoryVersion
    });
    await expectEvent(res1.receipt, "ERC721AuctionDeployed", {
      deployer: wallet1,
      urlName: "Bob",
      instance: nftAddressesBob[nftAddressesBob.length - 1].contractAddress,
      factoryVersion: factoryVersion
    });
  });
});
