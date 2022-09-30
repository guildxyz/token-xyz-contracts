const { BN, ether, expectEvent, expectRevert } = require("@openzeppelin/test-helpers");
const { expectRevertCustomError } = require("custom-error-test-helper");
const expect = require("chai").expect;

const ERC20InitialSupply = artifacts.require("ERC20InitialSupply");
const ERC20MintableOwned = artifacts.require("ERC20MintableOwned");
const ERC20MintableOwnedMaxSupply = artifacts.require("ERC20MintableOwnedMaxSupply");
const ERC20MintableAccessControlled = artifacts.require("ERC20MintableAccessControlled");
const ERC20MintableAccessControlledMaxSupply = artifacts.require("ERC20MintableAccessControlledMaxSupply");

const tokenName = "OwoToken";
const tokenSymbol = "OWO";
const tokenDecimals = new BN(18);
const initialSupply = new BN(ether("1000"));
let token;

const runOptions = [
  {
    context: "mintable ownable tokens",
    contextMax: "mintable ownable tokens with max supply",
    ERC20Mintable: ERC20MintableOwned,
    ERC20MintableMaxSupply: ERC20MintableOwnedMaxSupply
  },
  {
    context: "mintable accesscontrolled tokens",
    contextMax: "mintable accesscontrolled tokens with max supply",
    ERC20Mintable: ERC20MintableAccessControlled,
    ERC20MintableMaxSupply: ERC20MintableAccessControlledMaxSupply
  }
];

contract("ERC20 contracts", function (accounts) {
  const [wallet0, wallet1] = accounts;

  context("fixed supply tokens", function () {
    before("create a token", async function () {
      token = await ERC20InitialSupply.new(tokenName, tokenSymbol, tokenDecimals, wallet0, initialSupply);
    });

    it("should have correct metadata", async function () {
      const name = await token.name();
      const symbol = await token.symbol();
      const decimals = await token.decimals();
      expect(name).to.eq(tokenName);
      expect(symbol).to.eq(tokenSymbol);
      expect(decimals).to.bignumber.eq(tokenDecimals);
    });

    it("should have a total supply equal to the initial supply", async function () {
      const totalSupply = await token.totalSupply();
      expect(totalSupply).to.bignumber.eq(initialSupply);
    });

    it("should have minted the initial supply to the correct address", async function () {
      const balance = await token.balanceOf(wallet0);
      expect(balance).to.bignumber.eq(initialSupply);
    });

    it("should fail to be minted", async function () {
      const tokenContract = await ERC20MintableOwned.at(token.address);
      await expectRevert.unspecified(tokenContract.mint(wallet1, "1"));
    });
  });

  for (const runOption of runOptions) {
    context(runOption.context, function () {
      before("create a token", async function () {
        token = await runOption.ERC20Mintable.new(tokenName, tokenSymbol, tokenDecimals, wallet0, initialSupply);
      });

      it("should have correct metadata & owner", async function () {
        const name = await token.name();
        const symbol = await token.symbol();
        const decimals = await token.decimals();
        expect(name).to.eq(tokenName);
        expect(symbol).to.eq(tokenSymbol);
        expect(decimals).to.bignumber.eq(tokenDecimals);
        if (runOption.context.includes("own")) {
          const owner = await token.owner();
          expect(owner).to.eq(wallet0);
        } else {
          const minterRole = await token.MINTER_ROLE();
          await expectEvent.inConstruction(token, "RoleGranted", { role: minterRole, account: wallet0 });
        }
      });

      it("should have a total supply equal to the initial supply", async function () {
        const totalSupply = await token.totalSupply();
        expect(totalSupply).to.bignumber.eq(initialSupply);
      });

      it("should have minted the initial supply to the correct address", async function () {
        const balance = await token.balanceOf(wallet0);
        expect(balance).to.bignumber.eq(initialSupply);
      });

      it("should really be mintable", async function () {
        const oldBalance = await token.balanceOf(wallet1);
        const amountToMint = ether("1");
        await token.mint(wallet1, amountToMint);
        const newBalance = await token.balanceOf(wallet1);
        expect(newBalance).to.bignumber.eq(oldBalance.add(amountToMint));
      });
    });

    context(runOption.contextMax, async function () {
      const maxSupply = initialSupply.mul(new BN(2));

      before("create a token", async function () {
        token = await runOption.ERC20MintableMaxSupply.new(
          tokenName,
          tokenSymbol,
          tokenDecimals,
          wallet0,
          initialSupply,
          maxSupply
        );
      });

      it("should have correct metadata & owner", async function () {
        const name = await token.name();
        const symbol = await token.symbol();
        const decimals = await token.decimals();
        expect(name).to.eq(tokenName);
        expect(symbol).to.eq(tokenSymbol);
        expect(decimals).to.bignumber.eq(tokenDecimals);
        if (runOption.context.includes("own")) {
          const owner = await token.owner();
          expect(owner).to.eq(wallet0);
        } else {
          const minterRole = await token.MINTER_ROLE();
          await expectEvent.inConstruction(token, "RoleGranted", { role: minterRole, account: wallet0 });
        }
      });

      it("should have a total supply equal to the initial supply", async function () {
        const totalSupply = await token.totalSupply();
        expect(totalSupply).to.bignumber.eq(initialSupply);
      });

      it("should have minted the initial supply to the correct address", async function () {
        const balance = await token.balanceOf(wallet0);
        expect(balance).to.bignumber.eq(initialSupply);
      });

      it("should really be mintable", async function () {
        const oldBalance = await token.balanceOf(wallet1);
        const amountToMint = ether("1");
        await token.mint(wallet1, amountToMint);
        const newBalance = await token.balanceOf(wallet1);
        expect(newBalance).to.bignumber.eq(oldBalance.add(amountToMint));
      });

      it("should have a max supply", async function () {
        expect(await token.maxSupply()).to.bignumber.eq(maxSupply);
      });

      it("should revert if max supply is lower than initial supply", async function () {
        const lowMaxSupply = initialSupply.div(new BN(2));
        await expectRevertCustomError(
          runOption.ERC20MintableMaxSupply,
          runOption.ERC20MintableMaxSupply.new(
            tokenName,
            tokenSymbol,
            tokenDecimals,
            wallet0,
            initialSupply,
            lowMaxSupply
          ),
          "MaxSupplyTooLow",
          [lowMaxSupply, initialSupply]
        );
      });

      it("should fail to mint more tokens if max supply is exceeded", async function () {
        const totalSupply = await token.totalSupply();
        const amountToBeMinted = maxSupply.sub(totalSupply).add(new BN(1));
        await expectRevertCustomError(
          runOption.ERC20MintableMaxSupply,
          token.mint(wallet1, amountToBeMinted),
          "MaxSupplyExceeded",
          [amountToBeMinted, totalSupply, maxSupply]
        );
      });
    });
  }
});
