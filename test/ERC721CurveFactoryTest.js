const { utils } = require("ethers");
const { expectEvent } = require("@openzeppelin/test-helpers");
const expect = require("chai").expect;

const InitialMigration = artifacts.require("InitialMigration");
const TokenXyz = artifacts.require("TokenXyz");
const ITokenXyz = artifacts.require("ITokenXyz");
const SimpleFunctionRegistryFeature = artifacts.require("SimpleFunctionRegistryFeature");
const OwnableFeature = artifacts.require("OwnableFeature");
const ERC721CurveFactoryFeature = artifacts.require("ERC721CurveFactoryFeature");
const ERC721Curve = artifacts.require("ERC721Curve");

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

contract("ERC721CurveFactory", function (accounts) {
  const [wallet0, wallet1] = accounts;
  let tokenXyz;
  let erc721CurveFactory;

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
    erc721CurveFactory = await ERC721CurveFactoryFeature.new();
    const migrateInterface = new utils.Interface(["function migrate()"]);
    await tokenXyz.migrate(erc721CurveFactory.address, migrateInterface.encodeFunctionData("migrate()"), wallet0);
  });

  it("saves deployed tokens' addresses", async function () {
    await tokenXyz.createNFTWithCurve("Alice", nftMetadata0, 42069, wallet0);
    await tokenXyz.createNFTWithCurve("Alice", nftMetadata1, 69420, wallet0, { from: wallet1 });
    await tokenXyz.createNFTWithCurve("Bob", nftMetadata0, 42069, wallet1, { from: wallet1 });
    const nftAddressesAlice = await tokenXyz.getDeployedNFTsWithCurve("Alice");
    const nftAddressesBob = await tokenXyz.getDeployedNFTsWithCurve("Bob");
    const factoryVersion = await erc721CurveFactory.FEATURE_VERSION();
    expect(nftAddressesAlice.length).to.eq(2);
    expect(nftAddressesBob.length).to.eq(1);
    expect(nftAddressesAlice[0].factoryVersion).to.bignumber.eq(factoryVersion);
    expect(nftAddressesAlice[1].factoryVersion).to.bignumber.eq(factoryVersion);
    expect(nftAddressesBob[0].factoryVersion).to.bignumber.eq(factoryVersion);
  });

  it("creates nft contracts with the right parameters", async function () {
    const nftAddressesAlice = await tokenXyz.getDeployedNFTsWithCurve("Alice");
    const nftAddressesBob = await tokenXyz.getDeployedNFTsWithCurve("Bob");
    const nftAlice0 = await ERC721Curve.at(nftAddressesAlice[0].contractAddress);
    const nftAlice1 = await ERC721Curve.at(nftAddressesAlice[1].contractAddress);
    const nftBob0 = await ERC721Curve.at(nftAddressesBob[0].contractAddress);
    expect(await nftAlice0.name()).to.eq(nftMetadata0.name);
    expect(await nftAlice1.name()).to.eq(nftMetadata1.name);
    expect(await nftBob0.name()).to.eq(nftMetadata0.name);
    expect(await nftAlice0.symbol()).to.eq(nftMetadata0.symbol);
    expect(await nftAlice1.symbol()).to.eq(nftMetadata1.symbol);
    expect(await nftBob0.symbol()).to.eq(nftMetadata0.symbol);
    expect(await nftAlice0.maxSupply()).to.bignumber.eq(nftMetadata0.maxSupply);
    expect(await nftAlice1.maxSupply()).to.bignumber.eq(nftMetadata1.maxSupply);
    expect(await nftBob0.maxSupply()).to.bignumber.eq(nftMetadata0.maxSupply);
    expect(await nftAlice0.startingPrice()).to.bignumber.eq("42069");
    expect(await nftAlice1.startingPrice()).to.bignumber.eq("69420");
    expect(await nftBob0.startingPrice()).to.bignumber.eq("42069");
    expect(await nftAlice0.owner()).to.eq(wallet0);
    expect(await nftAlice1.owner()).to.eq(wallet0);
    expect(await nftBob0.owner()).to.eq(wallet1);
  });

  it("emits ERC721CurveDeployed event", async function () {
    const res0 = await tokenXyz.createNFTWithCurve("Alice", nftMetadata0, 42069, wallet0);
    const res1 = await tokenXyz.createNFTWithCurve("Bob", nftMetadata0, 42069, wallet1, { from: wallet1 });
    const nftAddressesAlice = await tokenXyz.getDeployedNFTsWithCurve("Alice");
    const nftAddressesBob = await tokenXyz.getDeployedNFTsWithCurve("Bob");
    const factoryVersion = await erc721CurveFactory.FEATURE_VERSION();
    await expectEvent(res0.receipt, "ERC721CurveDeployed", {
      deployer: wallet0,
      urlName: "Alice",
      instance: nftAddressesAlice[nftAddressesAlice.length - 1].contractAddress,
      factoryVersion: factoryVersion
    });
    await expectEvent(res1.receipt, "ERC721CurveDeployed", {
      deployer: wallet1,
      urlName: "Bob",
      instance: nftAddressesBob[nftAddressesBob.length - 1].contractAddress,
      factoryVersion: factoryVersion
    });
  });
});
