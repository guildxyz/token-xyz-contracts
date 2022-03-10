const { utils } = require("ethers");
const { BN, ether, expectEvent, expectRevert } = require("@openzeppelin/test-helpers");
const expect = require("chai").expect;

const InitialMigration = artifacts.require("InitialMigration");
const TokenXyz = artifacts.require("TokenXyz");
const ITokenXyz = artifacts.require("ITokenXyz");
const SimpleFunctionRegistryFeature = artifacts.require("SimpleFunctionRegistryFeature");
const OwnableFeature = artifacts.require("OwnableFeature");
const TokenFactoryFeature = artifacts.require("TokenFactoryFeature");
const TokenWithRolesFactoryFeature = artifacts.require("TokenWithRolesFactoryFeature");

const ERC20InitialSupply = artifacts.require("ERC20InitialSupply");
const ERC20MintableOwned = artifacts.require("ERC20MintableOwned");
const ERC20MintableOwnedMaxSupply = artifacts.require("ERC20MintableOwnedMaxSupply");
const ERC20MintableAccessControlled = artifacts.require("ERC20MintableAccessControlled");
const ERC20MintableAccessControlledMaxSupply = artifacts.require("ERC20MintableAccessControlledMaxSupply");

function getEventArg(logs, eventName, eventArg) {
  for (elem of logs) if (elem.event === eventName) return elem.args[eventArg];
}

const tokenName = "OwoToken";
const tokenSymbol = "OWO";
const tokenDecimals = new BN(18);
const initialSupply = new BN(ether("1000"));

// TODO: same for AccessControlled version. This should be generalized in a way.

contract("TokenFactory & TokenWithRolesFactory", function (accounts) {
  const [wallet0, wallet1] = accounts;
  let tokenXyz;

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
    const tokenFactory = await TokenFactoryFeature.new();
    const tokenWithRolesFactory = await TokenWithRolesFactoryFeature.new();
    const migrateInterface = new utils.Interface(["function migrate()"]);
    await tokenXyz.migrate(tokenFactory.address, migrateInterface.encodeFunctionData("migrate()"), wallet0);
    await tokenXyz.migrate(tokenWithRolesFactory.address, migrateInterface.encodeFunctionData("migrate()"), wallet0);
  });

  it("saves deployed tokens' addresses", async function () {
    await tokenXyz.createToken("Alice", "Alice0", tokenSymbol, tokenDecimals, 0, initialSupply, wallet0);
    await tokenXyz.createToken("Alice", "Alice1", tokenSymbol, tokenDecimals, initialSupply, 0, wallet0);
    await tokenXyz.createToken("Bob", "Bob0", tokenSymbol, tokenDecimals, initialSupply, 0, wallet0);
    const tokenAddressesAlice = await tokenXyz.getDeployedTokens("Alice");
    const tokenAddressesBob = await tokenXyz.getDeployedTokens("Bob");
    const tokenAlice0 = await ERC20MintableOwned.at(tokenAddressesAlice[0]);
    const tokenAlice1 = await ERC20MintableOwned.at(tokenAddressesAlice[1]);
    const tokenBob0 = await ERC20MintableOwned.at(tokenAddressesBob[0]);
    expect(tokenAddressesAlice.length).to.eq(2);
    expect(tokenAddressesBob.length).to.eq(1);
    expect(await tokenAlice0.name()).to.eq("Alice0");
    expect(await tokenAlice1.name()).to.eq("Alice1");
    expect(await tokenBob0.name()).to.eq("Bob0");
  });

  it("emits TokenDeployed event", async function () {
    const res0 = await tokenXyz.createToken("Alice", "Alice0", tokenSymbol, tokenDecimals, 0, 0, wallet0);
    const res1 = await tokenXyz.createToken("Bob", "Bob0", tokenSymbol, tokenDecimals, 0, 0, wallet0);
    const tokenAddressesAlice = await tokenXyz.getDeployedTokens("Alice");
    const tokenAddressesBob = await tokenXyz.getDeployedTokens("Bob");
    await expectEvent(res0.receipt, "TokenDeployed", {
      deployer: wallet0,
      urlName: "Alice",
      token: tokenAddressesAlice[tokenAddressesAlice.length - 1]
    });
    await expectEvent(res1.receipt, "TokenDeployed", {
      deployer: wallet0,
      urlName: "Bob",
      token: tokenAddressesBob[tokenAddressesBob.length - 1]
    });
  });

  context("fixed supply tokens", function () {
    let tokenAddress;

    beforeEach("create a token", async function () {
      const result = await tokenXyz.createToken(
        "Test",
        tokenName,
        tokenSymbol,
        tokenDecimals,
        initialSupply,
        initialSupply,
        wallet0
      );
      // get deployed token from events
      tokenAddress = getEventArg(result.receipt.logs, "TokenDeployed", "token");
    });

    it("should have correct metadata", async function () {
      const tokenContract = await ERC20InitialSupply.at(tokenAddress);
      const name = await tokenContract.name();
      const symbol = await tokenContract.symbol();
      const decimals = await tokenContract.decimals();
      expect(name).to.eq(tokenName);
      expect(symbol).to.eq(tokenSymbol);
      expect(decimals).to.bignumber.eq(tokenDecimals);
    });

    it("should have a total supply equal to the initial supply", async function () {
      const tokenContract = await ERC20InitialSupply.at(tokenAddress);
      const totalSupply = await tokenContract.totalSupply();
      expect(totalSupply).to.bignumber.eq(initialSupply);
    });

    it("should fail to be minted", async function () {
      const tokenContract = await ERC20MintableOwned.at(tokenAddress);
      await expectRevert.unspecified(tokenContract.mint(wallet1, "1"));
    });
  });

  context("mintable tokens", function () {
    it("should have correct metadata & owner", async function () {
      const creation = await tokenXyz.createToken(
        "Test",
        tokenName,
        tokenSymbol,
        tokenDecimals,
        initialSupply,
        0,
        wallet0
      );
      const tokenContract = await ERC20MintableOwned.at(getEventArg(creation.receipt.logs, "TokenDeployed", "token"));
      const name = await tokenContract.name();
      const symbol = await tokenContract.symbol();
      const decimals = await tokenContract.decimals();
      const owner = await tokenContract.owner();
      expect(name).to.eq(tokenName);
      expect(symbol).to.eq(tokenSymbol);
      expect(decimals).to.bignumber.eq(tokenDecimals);
      expect(owner).to.eq(wallet0);
    });

    it("should really be mintable if initialSupply < maxSupply or either of them is zero", async function () {
      const creation0 = await tokenXyz.createToken(
        "Test",
        tokenName,
        tokenSymbol,
        tokenDecimals,
        0,
        initialSupply,
        wallet0
      );
      const creation1 = await tokenXyz.createToken(
        "Test",
        tokenName,
        tokenSymbol,
        tokenDecimals,
        initialSupply,
        0,
        wallet0
      );
      const creation2 = await tokenXyz.createToken(
        "Test",
        tokenName,
        tokenSymbol,
        tokenDecimals,
        initialSupply,
        initialSupply.mul(new BN(2)),
        wallet0
      );
      const tokenContracts = [
        await ERC20MintableOwned.at(getEventArg(creation0.receipt.logs, "TokenDeployed", "token")),
        await ERC20MintableOwned.at(getEventArg(creation1.receipt.logs, "TokenDeployed", "token")),
        await ERC20MintableOwned.at(getEventArg(creation2.receipt.logs, "TokenDeployed", "token"))
      ];
      tokenContracts.forEach(async (tokenContract) => {
        const oldBalance = await tokenContract.balanceOf(wallet1);
        const amountToMint = ether("1");
        await tokenContract.mint(wallet1, amountToMint);
        const newBalance = await tokenContract.balanceOf(wallet1);
        expect(newBalance).to.bignumber.eq(oldBalance.add(amountToMint));
      });
    });

    it("should have max supply if and only if non-zero was set", async function () {
      const unlimitedCreation = await tokenXyz.createToken(
        "Test",
        tokenName,
        tokenSymbol,
        tokenDecimals,
        initialSupply,
        0,
        wallet0
      );
      const unlimitedTokenContract = await ERC20MintableOwnedMaxSupply.at(
        getEventArg(unlimitedCreation.receipt.logs, "TokenDeployed", "token")
      );
      const maxSupply = initialSupply.mul(new BN(2));
      const maxSupplyCreation = await tokenXyz.createToken(
        "Test",
        tokenName,
        tokenSymbol,
        tokenDecimals,
        initialSupply,
        maxSupply,
        wallet0
      );
      const maxSupplyTokenContract = await ERC20MintableOwnedMaxSupply.at(
        getEventArg(maxSupplyCreation.receipt.logs, "TokenDeployed", "token")
      );
      expect(await maxSupplyTokenContract.maxSupply()).to.bignumber.eq(maxSupply);
      await expectRevert.unspecified(unlimitedTokenContract.maxSupply());
    });

    it("should revert if max supply is lower than initial supply", async function () {
      await expectRevert.unspecified(
        tokenXyz.createToken(
          "Test",
          tokenName,
          tokenSymbol,
          tokenDecimals,
          initialSupply,
          initialSupply.div(new BN(2)),
          wallet0
        )
      );
    });
  });
});
