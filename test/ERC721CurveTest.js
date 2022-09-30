const { balance, BN, constants, ether, expectEvent, expectRevert } = require("@openzeppelin/test-helpers");
const { expectRevertCustomError } = require("custom-error-test-helper");
const expect = require("chai").expect;

const ERC721Curve = artifacts.require("ERC721Curve");

const tokenName = "FireNFT";
const tokenSymbol = "FNFT";
const tokenCid = "QmPaZD7i8TpLEeGjHtGoXe4mPKbRNNt8YTHH5nrKoqz9wJ";
const tokenMaxSupply = new BN(3);
const tokenStartingPrice = new BN(ether("0.01"));

function getTokenPrice(tokenId) {
  // (startingPrice * maxSupply ** 2) / (maxSupply - tokenId) ** 2;
  return tokenStartingPrice.mul(tokenMaxSupply.pow(new BN(2))).div(tokenMaxSupply.sub(new BN(tokenId)).pow(new BN(2)));
}

contract("ERC721 with curve", function (accounts) {
  const [wallet0, wallet1] = accounts;
  let token;

  beforeEach("create a token", async function () {
    token = await ERC721Curve.new(tokenName, tokenSymbol, tokenCid, tokenMaxSupply, tokenStartingPrice, wallet0);
  });

  it("creation fails if called with invalid parameters", async function () {
    await expectRevertCustomError(
      ERC721Curve,
      ERC721Curve.new(tokenName, tokenSymbol, tokenCid, 0, tokenStartingPrice, wallet0),
      "MaxSupplyZero"
    );
    await expectRevertCustomError(
      ERC721Curve,
      ERC721Curve.new(tokenName, tokenSymbol, tokenCid, tokenMaxSupply, 0, wallet0),
      "StartingPriceZero"
    );
    await expectRevertCustomError(
      ERC721Curve,
      ERC721Curve.new(tokenName, tokenSymbol, tokenCid, tokenMaxSupply, tokenStartingPrice, constants.ZERO_ADDRESS),
      "InvalidParameters"
    );
  });

  it("should have correct metadata & owner", async function () {
    const name = await token.name();
    const symbol = await token.symbol();
    const maxSupply = await token.maxSupply();
    const startingPrice = await token.startingPrice();
    const owner = await token.owner();
    expect(name).to.eq(tokenName);
    expect(symbol).to.eq(tokenSymbol);
    expect(maxSupply).to.bignumber.eq(tokenMaxSupply);
    expect(startingPrice).to.bignumber.eq(tokenStartingPrice);
    expect(owner).to.eq(wallet0);
  });

  it("should have zero tokens initially", async function () {
    const totalSupply = await token.totalSupply();
    expect(totalSupply).to.bignumber.eq("0");
  });

  it("should fail to calculate the price of a token that will never exist", async function () {
    await expectRevertCustomError(ERC721Curve, token.getPriceOf(tokenMaxSupply), "TokenIdOutOfBounds", [
      tokenMaxSupply,
      tokenMaxSupply
    ]);
  });

  it("should correctly calculate the price of tokens", async function () {
    expect(await token.getPriceOf(0)).to.bignumber.eq(tokenStartingPrice);
    expect(await token.getPriceOf(1)).to.bignumber.eq(getTokenPrice(1));
    expect(await token.getPriceOf(2)).to.bignumber.eq(getTokenPrice(2));
  });

  it("should revert when trying to get the tokenURI for a non-existent token", async function () {
    await expectRevertCustomError(ERC721Curve, token.tokenURI(84), "NonExistentToken", [84]);
  });

  it("should return the correct tokenURI", async function () {
    await token.claim(wallet1, { value: tokenStartingPrice });
    const regex = new RegExp(`ipfs:\/\/${tokenCid}\/0.json`);
    expect(regex.test(await token.tokenURI(0))).to.be.true;
  });

  context("claiming", async function () {
    it("should fail to claim above maxSupply", async function () {
      await token.claim(wallet0, { value: tokenStartingPrice });
      await token.claim(wallet0, { value: getTokenPrice(1) });
      await token.claim(wallet0, { value: getTokenPrice(2) });
      await expectRevertCustomError(ERC721Curve, token.claim(wallet0, { value: ether("100") }), "TokenIdOutOfBounds", [
        3,
        tokenMaxSupply
      ]);
    });

    it("should fail to claim if did not receive enough ether", async function () {
      const amount = tokenStartingPrice.div(new BN(2));
      await expectRevertCustomError(ERC721Curve, token.claim(wallet0, { value: amount }), "PriceTooLow", [
        amount,
        tokenStartingPrice
      ]);
    });

    it("should give back any leftover ether if paid too much", async function () {
      const tracker = await balance.tracker(wallet0);
      await token.claim(wallet0, { value: tokenStartingPrice.mul(new BN(2)) });
      const { delta, fees } = await tracker.deltaWithFees();
      expect(delta).to.bignumber.eq(tokenStartingPrice.add(fees).mul(new BN(-1)));
    });

    it("claiming increases totalSupply", async function () {
      const totalSupply = await token.totalSupply();
      await token.claim(wallet0, { value: tokenStartingPrice });
      expect(await token.totalSupply()).to.bignumber.eq(totalSupply.add(new BN(1)));
    });

    it("should really be claimable", async function () {
      const oldBalance = await token.balanceOf(wallet1);
      await token.claim(wallet1, { value: tokenStartingPrice });
      const newBalance = await token.balanceOf(wallet1);
      expect(newBalance).to.bignumber.eq(oldBalance.add(new BN(1)));
    });
  });

  context("withdrawal", async function () {
    it("should fail if called by anyone but the owner", async function () {
      await expectRevert(token.withdraw(wallet0, { from: wallet1 }), "Ownable: caller is not the owner");
    });

    it("should send the whole balance of the contract to the specified address", async function () {
      const trackerOwner = await balance.tracker(wallet0);
      const trackerContract = await balance.tracker(token.address);
      await token.withdraw(wallet0);
      const { delta: deltaOwner, fees } = await trackerOwner.deltaWithFees();
      const deltaContract = await trackerContract.delta();
      expect(deltaOwner).to.bignumber.eq(deltaContract.mul(new BN(-1)).sub(fees));
      expect(await balance.current(token.address)).to.bignumber.eq(new BN(0));
    });

    it("emits Withdrawn event", async function () {
      const result = await token.withdraw(wallet0);
      const contractBalance = await balance.current(token.address);
      await expectEvent(result, "Withdrawn", { account: wallet0, amount: contractBalance });
    });
  });
});
