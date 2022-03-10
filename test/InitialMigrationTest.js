const { constants, utils } = require("ethers");
const { expectRevert } = require("@openzeppelin/test-helpers");
const expect = require("chai").expect;

const InitialMigration = artifacts.require("InitialMigration");
const TokenXyz = artifacts.require("TokenXyz");
const ITokenXyz = artifacts.require("ITokenXyz");
const SimpleFunctionRegistryFeature = artifacts.require("SimpleFunctionRegistryFeature");
const OwnableFeature = artifacts.require("OwnableFeature");
const TokenFactoryFeature = artifacts.require("TokenFactoryFeature");

contract("InitialMigration", function (accounts) {
  const [wallet0, wallet1] = accounts;
  let initialMigration;
  let tokenXyz;
  let functionRegistry;
  let ownable;
  let features;

  beforeEach("deploy contracts", async function () {
    initialMigration = await InitialMigration.new(wallet0);
    tokenXyz = await TokenXyz.new(initialMigration.address);
    tokenXyz = await ITokenXyz.at(tokenXyz.address);
    functionRegistry = await SimpleFunctionRegistryFeature.new();
    ownable = await OwnableFeature.new();
    features = {
      registry: functionRegistry.address,
      ownable: ownable.address
    };
  });

  it("self-destructs after initializing", async function () {
    await initialMigration.initializeTokenXyz(wallet0, tokenXyz.address, features);
    const contractCode = await web3.eth.getCode(initialMigration.address);
    expect(contractCode).to.eq("0x");
  });

  it("non-deployer cannot call initializeTokenXyz()", async function () {
    await expectRevert(
      initialMigration.initializeTokenXyz(wallet0, tokenXyz.address, features, { from: wallet1 }),
      "InitialMigration/INVALID_SENDER"
    );
  });

  it("can add more features", async function () {
    // Deploy a TokenFactory and try to call a function from it.
    await initialMigration.initializeTokenXyz(wallet0, tokenXyz.address, features);
    const tokenFactory = await TokenFactoryFeature.new();
    const migrateInterface = new utils.Interface(["function migrate()"]);
    await tokenXyz.migrate(tokenFactory.address, migrateInterface.encodeFunctionData("migrate()"), wallet0);
    const result = await tokenXyz.createToken("owo", "OWO Token", "OWO", "18", 0, 1, wallet0);
    expect(result.receipt.status).to.be.true;
  });

  context("Ownable feature", function () {
    it("has the correct owner", async function () {
      await initialMigration.initializeTokenXyz(wallet0, tokenXyz.address, features);
      const actualOwner = await tokenXyz.owner();
      expect(actualOwner).to.eq(wallet0);
    });
  });

  context("SimpleFunctionRegistry feature", function () {
    it("_extendSelf() is deregistered", async function () {
      await initialMigration.initializeTokenXyz(wallet0, tokenXyz.address, features);
      const interface = new utils.Interface(["function _extendSelf(bytes4 selector, address impl)"]);
      const selector = interface.getSighash("_extendSelf");
      const tokenXyzWithOwnAbi = await TokenXyz.at(tokenXyz.address);
      expect(await tokenXyzWithOwnAbi.getFunctionImplementation(selector)).to.eq(constants.AddressZero);
    });
  });
});
