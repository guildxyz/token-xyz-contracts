const { utils } = require("ethers");
const { BN, ether, expectEvent, time } = require("@openzeppelin/test-helpers");
const expect = require("chai").expect;

const InitialMigration = artifacts.require("InitialMigration");
const TokenXyz = artifacts.require("TokenXyz");
const ITokenXyz = artifacts.require("ITokenXyz");
const SimpleFunctionRegistryFeature = artifacts.require("SimpleFunctionRegistryFeature");
const OwnableFeature = artifacts.require("OwnableFeature");
const MerkleDistributorFactoryFeature = artifacts.require("MerkleDistributorFactoryFeature");
const MerkleDistributor = artifacts.require("MerkleDistributor");
const ERC20InitialSupply = artifacts.require("ERC20InitialSupply");

const randomRoot = "0xf7f77ea15719ea30bd2a584962ab273b1116f0e70fe80bbb0b30557d0addb7f3";

contract("MerkleDistributorFactory", function (accounts) {
  const [wallet0, wallet1] = accounts;
  let tokenXyz;
  let merkleDistributorFactory;
  let token;

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
    merkleDistributorFactory = await MerkleDistributorFactoryFeature.new();
    const migrateInterface = new utils.Interface(["function migrate()"]);
    await tokenXyz.migrate(merkleDistributorFactory.address, migrateInterface.encodeFunctionData("migrate()"), wallet0);
    token = await ERC20InitialSupply.new("OwoToken", "OWO", 18, wallet0, ether("1000"));
  });

  it("saves deployed airdrops' addresses", async function () {
    await tokenXyz.createAirdrop("Alice", token.address, randomRoot, 42069, wallet0);
    await tokenXyz.createAirdrop("Alice", token.address, randomRoot, 69420, wallet0, { from: wallet1 });
    await tokenXyz.createAirdrop("Bob", token.address, randomRoot, 42069, wallet1, { from: wallet1 });
    const airdropAddressesAlice = await tokenXyz.getDeployedAirdrops("Alice");
    const airdropAddressesBob = await tokenXyz.getDeployedAirdrops("Bob");
    expect(airdropAddressesAlice.length).to.eq(2);
    expect(airdropAddressesBob.length).to.eq(1);
  });

  it("creates airdrop contracts with the right parameters", async function () {
    const airdropAddressesAlice = await tokenXyz.getDeployedAirdrops("Alice");
    const airdropAddressesBob = await tokenXyz.getDeployedAirdrops("Bob");
    const airdropAlice0 = await MerkleDistributor.at(airdropAddressesAlice[0]);
    const airdropAlice1 = await MerkleDistributor.at(airdropAddressesAlice[1]);
    const airdropBob0 = await MerkleDistributor.at(airdropAddressesBob[0]);
    const blockTime = await time.latest();
    expect(await airdropAlice0.token()).to.eq(token.address);
    expect(await airdropAlice1.token()).to.eq(token.address);
    expect(await airdropBob0.token()).to.eq(token.address);
    expect(await airdropAlice0.merkleRoot()).to.eq(randomRoot);
    expect(await airdropAlice1.merkleRoot()).to.eq(randomRoot);
    expect(await airdropBob0.merkleRoot()).to.eq(randomRoot);
    expect(await airdropAlice0.distributionEnd()).to.bignumber.closeTo(blockTime.add(new BN(42069)), "60");
    expect(await airdropAlice1.distributionEnd()).to.bignumber.closeTo(blockTime.add(new BN(69420)), "60");
    expect(await airdropBob0.distributionEnd()).to.bignumber.closeTo(blockTime.add(new BN(42069)), "60");
    expect(await airdropAlice0.owner()).to.eq(wallet0);
    expect(await airdropAlice1.owner()).to.eq(wallet0);
    expect(await airdropBob0.owner()).to.eq(wallet1);
  });

  it("emits MerkleDistributorDeployed event", async function () {
    const res0 = await tokenXyz.createAirdrop("Alice", token.address, randomRoot, 42069, wallet0);
    const res1 = await tokenXyz.createAirdrop("Bob", token.address, randomRoot, 42069, wallet1, { from: wallet1 });
    const airdropAddressesAlice = await tokenXyz.getDeployedAirdrops("Alice");
    const airdropAddressesBob = await tokenXyz.getDeployedAirdrops("Bob");
    const factoryVersion = await merkleDistributorFactory.FEATURE_VERSION();
    await expectEvent(res0.receipt, "MerkleDistributorDeployed", {
      deployer: wallet0,
      urlName: "Alice",
      instance: airdropAddressesAlice[airdropAddressesAlice.length - 1].contractAddress,
      factoryVersion: factoryVersion
    });
    await expectEvent(res1.receipt, "MerkleDistributorDeployed", {
      deployer: wallet1,
      urlName: "Bob",
      instance: airdropAddressesBob[airdropAddressesBob.length - 1].contractAddress,
      factoryVersion: factoryVersion
    });
  });
});
