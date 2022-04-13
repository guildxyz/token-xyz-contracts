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

const runOptions = [
  {
    contract: "TokenFactory",
    createToken: "createToken",
    TokenFactory: TokenFactoryFeature,
    ERC20Mintable: ERC20MintableOwned,
    ERC20MintableMaxSupply: ERC20MintableOwnedMaxSupply
  },
  {
    contract: "TokenWithRolesFactory",
    createToken: "createTokenWithRoles",
    TokenFactory: TokenWithRolesFactoryFeature,
    ERC20Mintable: ERC20MintableAccessControlled,
    ERC20MintableMaxSupply: ERC20MintableAccessControlledMaxSupply
  }
];

contract("TokenFactory", function (accounts) {
  const [wallet0, wallet1] = accounts;
  let tokenXyz;
  let tokenFactory;

  for (const runOption of runOptions) {
    context(runOption.contract, async function () {
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
        tokenFactory = await runOption.TokenFactory.new();
        const migrateInterface = new utils.Interface(["function migrate()"]);
        await tokenXyz.migrate(tokenFactory.address, migrateInterface.encodeFunctionData("migrate()"), wallet0);
      });

      it("saves deployed tokens' addresses", async function () {
        await tokenXyz[runOption.createToken]("Alice", "Alice0", tokenSymbol, tokenDecimals, 0, initialSupply, wallet0);
        await tokenXyz[runOption.createToken]("Alice", "Alice1", tokenSymbol, tokenDecimals, initialSupply, 0, wallet0);
        await tokenXyz[runOption.createToken]("Bob", "Bob0", tokenSymbol, tokenDecimals, initialSupply, 0, wallet0);
        const tokenAddressesAlice = await tokenXyz.getDeployedTokens("Alice");
        const tokenAddressesBob = await tokenXyz.getDeployedTokens("Bob");
        const tokenAlice0 = await runOption.ERC20Mintable.at(tokenAddressesAlice[0].contractAddress);
        const tokenAlice1 = await runOption.ERC20Mintable.at(tokenAddressesAlice[1].contractAddress);
        const tokenBob0 = await runOption.ERC20Mintable.at(tokenAddressesBob[0].contractAddress);
        const factoryVersion = await tokenFactory.FEATURE_VERSION();
        expect(tokenAddressesAlice.length).to.eq(2);
        expect(tokenAddressesBob.length).to.eq(1);
        expect(await tokenAlice0.name()).to.eq("Alice0");
        expect(await tokenAlice1.name()).to.eq("Alice1");
        expect(await tokenBob0.name()).to.eq("Bob0");
        expect(tokenAddressesAlice[0].factoryVersion).to.bignumber.eq(factoryVersion);
        expect(tokenAddressesAlice[1].factoryVersion).to.bignumber.eq(factoryVersion);
        expect(tokenAddressesBob[0].factoryVersion).to.bignumber.eq(factoryVersion);
      });

      it("emits TokenDeployed event", async function () {
        const res0 = await tokenXyz[runOption.createToken](
          "Alice",
          "Alice0",
          tokenSymbol,
          tokenDecimals,
          0,
          0,
          wallet0
        );
        const res1 = await tokenXyz[runOption.createToken]("Bob", "Bob0", tokenSymbol, tokenDecimals, 0, 0, wallet0);
        const tokenAddressesAlice = await tokenXyz.getDeployedTokens("Alice");
        const tokenAddressesBob = await tokenXyz.getDeployedTokens("Bob");
        const factoryVersion = await tokenFactory.FEATURE_VERSION();
        await expectEvent(res0.receipt, "TokenDeployed", {
          deployer: wallet0,
          urlName: "Alice",
          token: tokenAddressesAlice[tokenAddressesAlice.length - 1].contractAddress,
          factoryVersion: factoryVersion
        });
        await expectEvent(res1.receipt, "TokenDeployed", {
          deployer: wallet0,
          urlName: "Bob",
          token: tokenAddressesBob[tokenAddressesBob.length - 1].contractAddress,
          factoryVersion: factoryVersion
        });
      });

      context("fixed supply tokens", function () {
        let tokenAddress;

        beforeEach("create a token", async function () {
          const result = await tokenXyz[runOption.createToken](
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
          const tokenContract = await runOption.ERC20Mintable.at(tokenAddress);
          await expectRevert.unspecified(tokenContract.mint(wallet1, "1"));
        });
      });

      context("mintable tokens", function () {
        it("should have correct metadata & owner", async function () {
          const creation = await tokenXyz[runOption.createToken](
            "Test",
            tokenName,
            tokenSymbol,
            tokenDecimals,
            initialSupply,
            0,
            wallet0
          );
          const tokenContract = await runOption.ERC20Mintable.at(
            getEventArg(creation.receipt.logs, "TokenDeployed", "token")
          );

          const name = await tokenContract.name();
          const symbol = await tokenContract.symbol();
          const decimals = await tokenContract.decimals();
          expect(name).to.eq(tokenName);
          expect(symbol).to.eq(tokenSymbol);
          expect(decimals).to.bignumber.eq(tokenDecimals);

          if (runOption.contract === "TokenFactory") {
            const owner = await tokenContract.owner();
            expect(owner).to.eq(wallet0);
          } else {
            const MINTER_ROLE = await tokenContract.MINTER_ROLE();
            const peepsWithMinterRole = [];
            for (elem of creation.receipt.rawLogs)
              if (
                elem.topics[0] === "0x2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d" &&
                elem.topics[1] === MINTER_ROLE
              )
                peepsWithMinterRole.push(elem.topics[2]);
            expect(peepsWithMinterRole.length).to.eq(1);
            expect(`0x${peepsWithMinterRole[0].slice(26)}`).to.eq(wallet0.toLowerCase());
          }
        });

        it("should really be mintable if initialSupply < maxSupply or either of them is zero", async function () {
          const creation0 = await tokenXyz[runOption.createToken](
            "Test",
            tokenName,
            tokenSymbol,
            tokenDecimals,
            0,
            initialSupply,
            wallet0
          );
          const creation1 = await tokenXyz[runOption.createToken](
            "Test",
            tokenName,
            tokenSymbol,
            tokenDecimals,
            initialSupply,
            0,
            wallet0
          );
          const creation2 = await tokenXyz[runOption.createToken](
            "Test",
            tokenName,
            tokenSymbol,
            tokenDecimals,
            initialSupply,
            initialSupply.mul(new BN(2)),
            wallet0
          );
          const tokenContracts = [
            await runOption.ERC20Mintable.at(getEventArg(creation0.receipt.logs, "TokenDeployed", "token")),
            await runOption.ERC20Mintable.at(getEventArg(creation1.receipt.logs, "TokenDeployed", "token")),
            await runOption.ERC20Mintable.at(getEventArg(creation2.receipt.logs, "TokenDeployed", "token"))
          ];
          for (tokenContract of tokenContracts) {
            const oldBalance = await tokenContract.balanceOf(wallet1);
            const amountToMint = ether("1");
            await tokenContract.mint(wallet1, amountToMint);
            const newBalance = await tokenContract.balanceOf(wallet1);
            expect(newBalance).to.bignumber.eq(oldBalance.add(amountToMint));
          }
        });

        it("should have max supply if and only if non-zero was set", async function () {
          const unlimitedCreation = await tokenXyz[runOption.createToken](
            "Test",
            tokenName,
            tokenSymbol,
            tokenDecimals,
            initialSupply,
            0,
            wallet0
          );
          const unlimitedTokenContract = await runOption.ERC20MintableMaxSupply.at(
            getEventArg(unlimitedCreation.receipt.logs, "TokenDeployed", "token")
          );
          const maxSupply = initialSupply.mul(new BN(2));
          const maxSupplyCreation = await tokenXyz[runOption.createToken](
            "Test",
            tokenName,
            tokenSymbol,
            tokenDecimals,
            initialSupply,
            maxSupply,
            wallet0
          );
          const maxSupplyTokenContract = await runOption.ERC20MintableMaxSupply.at(
            getEventArg(maxSupplyCreation.receipt.logs, "TokenDeployed", "token")
          );
          expect(await maxSupplyTokenContract.maxSupply()).to.bignumber.eq(maxSupply);
          await expectRevert.unspecified(unlimitedTokenContract.maxSupply());
        });

        it("should revert if max supply is lower than initial supply", async function () {
          // error MaxSupplyTooLow(uint256 maxSupply, uint256 initialSupply);
          await expectRevert.unspecified(
            tokenXyz[runOption.createToken](
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
  }
});
