const { constants, utils } = require("ethers");
const { expectRevert } = require("@openzeppelin/test-helpers");
const expect = require("chai").expect;

const FullMigration = artifacts.require("FullMigration");
const TokenXyz = artifacts.require("TokenXyz");
const ITokenXyz = artifacts.require("ITokenXyz");
const SimpleFunctionRegistryFeature = artifacts.require("SimpleFunctionRegistryFeature");
const OwnableFeature = artifacts.require("OwnableFeature");
const MulticallFeature = artifacts.require("MulticallFeature");
const TokenFactoryFeature = artifacts.require("TokenFactoryFeature");
const TokenWithRolesFactoryFeature = artifacts.require("TokenWithRolesFactoryFeature");
const MerkleDistributorFactoryFeature = artifacts.require("MerkleDistributorFactoryFeature");
const MerkleVestingFactoryFeature = artifacts.require("MerkleVestingFactoryFeature");
const ERC721MerkleDropFactoryFeature = artifacts.require("ERC721MerkleDropFactoryFeature");
const ERC721CurveFactoryFeature = artifacts.require("ERC721CurveFactoryFeature");
const ERC721AuctionFactoryFeature = artifacts.require("ERC721AuctionFactoryFeature");

const tokenxyzInterface = new utils.Interface(ITokenXyz.abi);
const randomRoot = "0xf7f77ea15719ea30bd2a584962ab273b1116f0e70fe80bbb0b30557d0addb7f3";

contract("FullMigration", function (accounts) {
  const [wallet0, wallet1] = accounts;
  let fullMigration;
  let tokenXyzWithOwnAbi;
  let tokenXyz;
  let features;
  let functionRegistry;
  let ownable;
  let multicall;
  let tokenFactory;
  let tokenWithRolesFactory;
  let merkleDistributorFactory;
  let merkleVestingFactory;
  let erc721MerkleDropFactory;
  let erc721CurveFactory;
  let erc721AuctionFactory;

  beforeEach("deploy contracts", async function () {
    fullMigration = await FullMigration.new(wallet0);
    tokenXyzWithOwnAbi = await TokenXyz.new(await fullMigration.getBootstrapper());
    tokenXyz = await ITokenXyz.at(tokenXyzWithOwnAbi.address);
    functionRegistry = await SimpleFunctionRegistryFeature.new();
    ownable = await OwnableFeature.new();
    multicall = await MulticallFeature.new();
    tokenFactory = await TokenFactoryFeature.new();
    tokenWithRolesFactory = await TokenWithRolesFactoryFeature.new();
    merkleDistributorFactory = await MerkleDistributorFactoryFeature.new();
    merkleVestingFactory = await MerkleVestingFactoryFeature.new();
    erc721MerkleDropFactory = await ERC721MerkleDropFactoryFeature.new();
    erc721CurveFactory = await ERC721CurveFactoryFeature.new();
    erc721AuctionFactory = await ERC721AuctionFactoryFeature.new(wallet0);
    features = {
      registry: functionRegistry.address,
      ownable: ownable.address,
      multicall: multicall.address,
      tokenFactory: tokenFactory.address,
      tokenWithRolesFactory: tokenWithRolesFactory.address,
      merkleDistributorFactory: merkleDistributorFactory.address,
      merkleVestingFactory: merkleVestingFactory.address,
      erc721MerkleDropFactory: erc721MerkleDropFactory.address,
      erc721CurveFactory: erc721CurveFactory.address,
      erc721AuctionFactory: erc721AuctionFactory.address
    };
  });

  it("self-destructs after initializing", async function () {
    await fullMigration.migrateTokenXyz(wallet0, tokenXyz.address, features);
    const contractCode = await web3.eth.getCode(fullMigration.address);
    expect(contractCode).to.eq("0x");
  });

  it("non-deployer cannot call migrateTokenXyz()", async function () {
    await expectRevert(
      fullMigration.migrateTokenXyz(wallet0, tokenXyz.address, features, { from: wallet1 }),
      "FullMigration/INVALID_SENDER"
    );
  });

  context("Ownable feature", function () {
    it("has the correct owner", async function () {
      await fullMigration.migrateTokenXyz(wallet0, tokenXyz.address, features);
      const actualOwner = await tokenXyz.owner();
      expect(actualOwner).to.eq(wallet0);
    });
  });

  context("SimpleFunctionRegistry feature", function () {
    it("_extendSelf() is deregistered", async function () {
      await fullMigration.migrateTokenXyz(wallet0, tokenXyz.address, features);
      const interface = new utils.Interface(SimpleFunctionRegistryFeature.abi);
      const selector = interface.getSighash("_extendSelf");
      expect(await tokenXyzWithOwnAbi.getFunctionImplementation(selector)).to.eq(constants.AddressZero);
    });
  });

  context("Factories", function () {
    beforeEach("migrate", async function () {
      await fullMigration.migrateTokenXyz(wallet0, tokenXyz.address, features);
    });

    it("token factory is available", async function () {
      const selector = tokenxyzInterface.getSighash("createToken");
      expect(await tokenXyzWithOwnAbi.getFunctionImplementation(selector)).to.eq(tokenFactory.address);
      const result = await tokenXyz.createToken("Test", "OwoToken", "OWO", 18, 10, 10, wallet0);
      expect(result.receipt.status).to.be.true;
    });

    it("accesscontrolled token factory is available", async function () {
      const selector = tokenxyzInterface.getSighash("createTokenWithRoles");
      expect(await tokenXyzWithOwnAbi.getFunctionImplementation(selector)).to.eq(tokenWithRolesFactory.address);
      const result = await tokenXyz.createTokenWithRoles("Test", "OwoToken", "OWO", 18, 10, 10, wallet0);
      expect(result.receipt.status).to.be.true;
    });

    it("airdrop factory is available", async function () {
      const selector = tokenxyzInterface.getSighash("createAirdrop");
      expect(await tokenXyzWithOwnAbi.getFunctionImplementation(selector)).to.eq(merkleDistributorFactory.address);
      const result = await tokenXyz.createAirdrop("Test", wallet0, randomRoot, 420, wallet0);
      expect(result.receipt.status).to.be.true;
    });

    it("vesting factory is available", async function () {
      const selector = tokenxyzInterface.getSighash("createVesting");
      expect(await tokenXyzWithOwnAbi.getFunctionImplementation(selector)).to.eq(merkleVestingFactory.address);
      const result = await tokenXyz.createVesting("Test", wallet0, wallet0);
      expect(result.receipt.status).to.be.true;
    });

    it("ERC721 Merkle Drop factory is available", async function () {
      const selector = tokenxyzInterface.getSighash("createNFTMerkleDrop");
      expect(await tokenXyzWithOwnAbi.getFunctionImplementation(selector)).to.eq(erc721MerkleDropFactory.address);
      const result = await tokenXyz.createNFTMerkleDrop(
        "Test",
        randomRoot,
        86400,
        { name: "name", symbol: "sym", ipfsHash: "cid", maxSupply: 1 },
        true,
        wallet0
      );
      expect(result.receipt.status).to.be.true;
    });

    it("ERC721 Curve factory is available", async function () {
      const selector = tokenxyzInterface.getSighash("createNFTWithCurve");
      expect(await tokenXyzWithOwnAbi.getFunctionImplementation(selector)).to.eq(erc721CurveFactory.address);
      const result = await tokenXyz.createNFTWithCurve(
        "Test",
        { name: "name", symbol: "sym", ipfsHash: "cid", maxSupply: 1 },
        420,
        wallet0
      );
      expect(result.receipt.status).to.be.true;
    });

    it("ERC721 Auction factory is available", async function () {
      const selector = tokenxyzInterface.getSighash("createNFTAuction");
      expect(await tokenXyzWithOwnAbi.getFunctionImplementation(selector)).to.eq(erc721AuctionFactory.address);
      const result = await tokenXyz.createNFTAuction(
        "Test",
        { name: "name", symbol: "sym", ipfsHash: "cid", maxSupply: 1 },
        {
          startingPrice: 1,
          auctionDuration: 500,
          timeBuffer: 100,
          minimumPercentageIncreasex100: 500
        },
        0,
        wallet0
      );
      expect(result.receipt.status).to.be.true;
    });

    it("they can be multicalled", async function () {
      const result = await tokenXyz.multicall([
        tokenxyzInterface.encodeFunctionData("createAirdrop", ["Test", wallet0, randomRoot, 420, wallet0]),
        tokenxyzInterface.encodeFunctionData("createVesting", ["Test", wallet0, wallet0])
      ]);
      expect(result.receipt.status).to.be.true;
    });
  });
});
