const { utils } = require("ethers");
const { ether, expectEvent } = require("@openzeppelin/test-helpers");
const expect = require("chai").expect;

const InitialMigration = artifacts.require("InitialMigration");
const TokenXyz = artifacts.require("TokenXyz");
const ITokenXyz = artifacts.require("ITokenXyz");
const SimpleFunctionRegistryFeature = artifacts.require("SimpleFunctionRegistryFeature");
const OwnableFeature = artifacts.require("OwnableFeature");
const MerkleVestingFactoryFeature = artifacts.require("MerkleVestingFactoryFeature");
const MerkleVesting = artifacts.require("MerkleVesting");
const ERC20InitialSupply = artifacts.require("ERC20InitialSupply");

contract("MerkleVestingFactory", function (accounts) {
  const [wallet0, wallet1] = accounts;
  let tokenXyz;
  let merkleVestingFactory;
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
    merkleVestingFactory = await MerkleVestingFactoryFeature.new();
    const migrateInterface = new utils.Interface(["function migrate()"]);
    await tokenXyz.migrate(merkleVestingFactory.address, migrateInterface.encodeFunctionData("migrate()"), wallet0);
    token = await ERC20InitialSupply.new("OwoToken", "OWO", 18, wallet0, ether("1000"));
  });

  it("saves deployed vestings' addresses", async function () {
    await tokenXyz.createVesting("Alice", token.address, wallet0);
    await tokenXyz.createVesting("Alice", token.address, wallet0, { from: wallet1 });
    await tokenXyz.createVesting("Bob", token.address, wallet1, { from: wallet1 });
    const vestingAddressesAlice = await tokenXyz.getDeployedVestings("Alice");
    const vestingAddressesBob = await tokenXyz.getDeployedVestings("Bob");
    expect(vestingAddressesAlice.length).to.eq(2);
    expect(vestingAddressesBob.length).to.eq(1);
  });

  it("creates vesting contracts with the right parameters", async function () {
    const vestingAddressesAlice = await tokenXyz.getDeployedVestings("Alice");
    const vestingAddressesBob = await tokenXyz.getDeployedVestings("Bob");
    const vestingAlice0 = await MerkleVesting.at(vestingAddressesAlice[0]);
    const vestingAlice1 = await MerkleVesting.at(vestingAddressesAlice[1]);
    const vestingBob0 = await MerkleVesting.at(vestingAddressesBob[0]);
    expect(await vestingAlice0.token()).to.eq(token.address);
    expect(await vestingAlice1.token()).to.eq(token.address);
    expect(await vestingBob0.token()).to.eq(token.address);
    expect(await vestingAlice0.owner()).to.eq(wallet0);
    expect(await vestingAlice1.owner()).to.eq(wallet0);
    expect(await vestingBob0.owner()).to.eq(wallet1);
  });

  it("emits MerkleVestingDeployed event", async function () {
    const res0 = await tokenXyz.createVesting("Alice", token.address, wallet0);
    const res1 = await tokenXyz.createVesting("Bob", token.address, wallet1, { from: wallet1 });
    const vestingAddressesAlice = await tokenXyz.getDeployedVestings("Alice");
    const vestingAddressesBob = await tokenXyz.getDeployedVestings("Bob");
    const factoryVersion = await merkleVestingFactory.FEATURE_VERSION();
    await expectEvent(res0.receipt, "MerkleVestingDeployed", {
      deployer: wallet0,
      urlName: "Alice",
      instance: vestingAddressesAlice[vestingAddressesAlice.length - 1].contractAddress,
      factoryVersion: factoryVersion
    });
    await expectEvent(res1.receipt, "MerkleVestingDeployed", {
      deployer: wallet1,
      urlName: "Bob",
      instance: vestingAddressesBob[vestingAddressesBob.length - 1].contractAddress,
      factoryVersion: factoryVersion
    });
  });
});
