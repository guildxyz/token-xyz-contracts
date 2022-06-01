const { balance, BN, constants, ether, expectEvent, expectRevert, time } = require("@openzeppelin/test-helpers");
const expect = require("chai").expect;

const ERC721Auction = artifacts.require("ERC721Auction");

const tokenName = "SupercoolNFT";
const tokenSymbol = "SNFT";
const tokenCid = "QmPaZD7i8TpLEeGjHtGoXe4mPKbRNNt8YTHH5nrKoqz9wJ";
const tokenMaxSupply = new BN(3);
const startingPrice = new BN(ether("0.01"));
const auctionDuration = new BN(86400);
const timeBuffer = new BN(300);
const minimumPercentageIncreasex100 = new BN(500);

contract("ERC721 auction", function (accounts) {
  const [wallet0, wallet1] = accounts;
  let token;

  beforeEach("create a token", async function () {
    token = await ERC721Auction.new(
      tokenName,
      tokenSymbol,
      tokenCid,
      tokenMaxSupply,
      startingPrice,
      auctionDuration,
      timeBuffer,
      minimumPercentageIncreasex100,
      0,
      wallet0
    );
  });

  it("creation fails if called with invalid parameters", async function () {
    // error MaxSupplyZero();
    await expectRevert(
      ERC721Auction.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        0,
        startingPrice,
        auctionDuration,
        timeBuffer,
        minimumPercentageIncreasex100,
        0,
        wallet0
      ),
      "Custom error (could not decode)"
    );
    // error StartingPriceZero();
    await expectRevert(
      ERC721Auction.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        tokenMaxSupply,
        0,
        auctionDuration,
        timeBuffer,
        minimumPercentageIncreasex100,
        0,
        wallet0
      ),
      "Custom error (could not decode)"
    );
    // error InvalidParameters();
    await expectRevert(
      ERC721Auction.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        tokenMaxSupply,
        startingPrice,
        0,
        timeBuffer,
        minimumPercentageIncreasex100,
        0,
        wallet0
      ),
      "Custom error (could not decode)"
    );
    // error InvalidParameters();
    await expectRevert(
      ERC721Auction.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        tokenMaxSupply,
        startingPrice,
        auctionDuration,
        timeBuffer,
        minimumPercentageIncreasex100,
        0,
        constants.ZERO_ADDRESS
      ),
      "Custom error (could not decode)"
    );
  });

  it("should have correct metadata & details", async function () {
    const name = await token.name();
    const symbol = await token.symbol();
    const maxSupply = await token.maxSupply();
    const startingPrice_ = await token.startingPrice();
    const auctionDuration_ = await token.auctionDuration();
    const timeBuffer_ = await token.timeBuffer();
    const minimumPercentageIncreasex100_ = await token.minimumPercentageIncreasex100();
    const owner = await token.owner();
    expect(name).to.eq(tokenName);
    expect(symbol).to.eq(tokenSymbol);
    expect(maxSupply).to.bignumber.eq(tokenMaxSupply);
    expect(startingPrice_).to.bignumber.eq(startingPrice);
    expect(auctionDuration_).to.bignumber.eq(auctionDuration);
    expect(timeBuffer_).to.bignumber.eq(timeBuffer);
    expect(minimumPercentageIncreasex100_).to.bignumber.eq(minimumPercentageIncreasex100);
    expect(owner).to.eq(wallet0);
  });

  it("should correctly create an auction and return it's state", async function () {
    const timestamp = await time.latest();
    const state0 = await token.getAuctionState();
    expect(state0.tokenId).to.bignumber.eq("0");
    expect(state0.bidder).to.eq(constants.ZERO_ADDRESS);
    expect(state0.bidAmount).to.bignumber.eq("0");
    expect(state0.startTime).to.bignumber.eq(timestamp);
    expect(state0.endTime).to.bignumber.eq(auctionDuration.add(new BN(state0.startTime)));

    const startTime1 = new BN(timestamp.add(new BN(42424)));
    const anotherToken = await ERC721Auction.new(
      tokenName,
      tokenSymbol,
      tokenCid,
      tokenMaxSupply,
      startingPrice,
      auctionDuration,
      timeBuffer,
      minimumPercentageIncreasex100,
      startTime1,
      wallet0
    );
    const state1 = await anotherToken.getAuctionState();
    expect(state1.tokenId).to.bignumber.eq("0");
    expect(state1.bidder).to.eq(constants.ZERO_ADDRESS);
    expect(state1.bidAmount).to.bignumber.eq("0");
    expect(state1.startTime).to.bignumber.eq(startTime1);
    expect(state1.endTime).to.bignumber.eq(auctionDuration.add(new BN(state1.startTime)));
  });

  it("should have zero tokens initially", async function () {
    const totalSupply = await token.totalSupply();
    expect(totalSupply).to.bignumber.eq("0");
  });

  it("should revert when trying to get the tokenURI for a non-existent token", async function () {
    // error NonExistentToken(uint256 tokenId);
    expectRevert.unspecified(token.tokenURI(84));
  });

  it("should return the correct tokenURI", async function () {
    await token.bid(0, { value: startingPrice });
    await time.increase(auctionDuration);
    await token.settleAuction();
    const regex = new RegExp(`ipfs:\/\/${tokenCid}\/0.json`);
    expect(regex.test(await token.tokenURI(0))).to.be.true;
  });

  context("auction parameters", function () {
    it("should fail to update startingPrice if not called by the owner", async function () {
      await expectRevert(token.setStartingPrice(42, { from: wallet1 }), "Ownable: caller is not the owner");
    });

    it("should fail to update startingPrice to zero", async function () {
      // error StartingPriceZero();
      await expectRevert.unspecified(token.setStartingPrice(0));
    });

    it("should fail to update auctionDuration if not called by the owner", async function () {
      await expectRevert(token.setAuctionDuration(42, { from: wallet1 }), "Ownable: caller is not the owner");
    });

    it("should fail to update auctionDuration to zero", async function () {
      // error InvalidParameters();
      await expectRevert.unspecified(token.setAuctionDuration(0));
    });

    it("should fail to update timeBuffer if not called by the owner", async function () {
      await expectRevert(token.setTimeBuffer(42, { from: wallet1 }), "Ownable: caller is not the owner");
    });

    it("should fail to update minimumPercentageIncreasex100 if not called by the owner", async function () {
      await expectRevert(
        token.setMinimumPercentageIncreasex100(400, { from: wallet1 }),
        "Ownable: caller is not the owner"
      );
    });

    it("should update startingPrice", async function () {
      const oldValue = await token.startingPrice();
      const desiredValue = ether("1");
      await token.setStartingPrice(desiredValue);
      const newValue = await token.startingPrice();
      expect(newValue).to.not.bignumber.eq(oldValue);
      expect(newValue).to.bignumber.eq(desiredValue);
    });

    it("should update auctionDuration", async function () {
      const oldValue = await token.auctionDuration();
      const desiredValue = "69420";
      await token.setAuctionDuration(desiredValue);
      const newValue = await token.auctionDuration();
      expect(newValue).to.not.bignumber.eq(oldValue);
      expect(newValue).to.bignumber.eq(desiredValue);
    });

    it("should update timeBuffer", async function () {
      const oldValue = await token.timeBuffer();
      const desiredValue = "120";
      await token.setTimeBuffer(desiredValue);
      const newValue = await token.timeBuffer();
      expect(newValue).to.not.bignumber.eq(oldValue);
      expect(newValue).to.bignumber.eq(desiredValue);
    });

    it("should update minimumPercentageIncreasex100", async function () {
      const oldValue = await token.minimumPercentageIncreasex100();
      const desiredValue = "200";
      await token.setMinimumPercentageIncreasex100(desiredValue);
      const newValue = await token.minimumPercentageIncreasex100();
      expect(newValue).to.not.bignumber.eq(oldValue);
      expect(newValue).to.bignumber.eq(desiredValue);
    });

    it("should emit StartingPriceChanged event", async function () {
      const desiredValue = ether("1");
      const result = await token.setStartingPrice(desiredValue);
      await expectEvent(result, "StartingPriceChanged", { newValue: desiredValue });
    });

    it("should emit AuctionDurationChanged event", async function () {
      const desiredValue = "69420";
      const result = await token.setAuctionDuration(desiredValue);
      await expectEvent(result, "AuctionDurationChanged", { newValue: desiredValue });
    });

    it("should emit TimeBufferChanged event", async function () {
      const desiredValue = "120";
      const result = await token.setTimeBuffer(desiredValue);
      await expectEvent(result, "TimeBufferChanged", { newValue: desiredValue });
    });

    it("should emit MinimumPercentageIncreasex100Changed event", async function () {
      const desiredValue = "200";
      const result = await token.setMinimumPercentageIncreasex100(desiredValue);
      await expectEvent(result, "MinimumPercentageIncreasex100Changed", { newValue: desiredValue });
    });
  });

  context("bidding", async function () {
    it("should fail if all tokens are already claimed", async function () {
      for (let i = 0; i < 2; i++) {
        await token.bid(i, { value: startingPrice.mul(new BN(i + 1)) });
        await time.increase(auctionDuration);
        await token.settleAuction();
      }
      // error TokenIdOutOfBounds(uint256 tokenId, uint256 maxSupply);
      await expectRevert.unspecified(token.bid(3));
    });

    it("should fail if bidding for another token", async function () {
      // error BidForAnotherToken(uint256 tokenId, uint256 currentAuctionId);
      await expectRevert.unspecified(token.bid(2));
    });

    it("should fail if bidding outside the auction's time frame", async function () {
      const timestamp = await time.latest();

      const aToken = await ERC721Auction.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        tokenMaxSupply,
        startingPrice,
        270,
        timeBuffer,
        minimumPercentageIncreasex100,
        timestamp.add(new BN(420)),
        wallet0
      );
      // error AuctionNotStarted(uint256 current, uint256 start);
      await expectRevert.unspecified(aToken.bid(0, { value: startingPrice }));

      await time.increase(690);
      // error AuctionEnded(uint256 current, uint256 end);
      await expectRevert.unspecified(aToken.bid(0, { value: startingPrice }));
    });

    it("should fail if the bid is too low", async function () {
      // error BidTooLow(uint256 paid, uint256 minBid);
      await expectRevert.unspecified(token.bid(0, { value: startingPrice.div(new BN(2)) }));
      await token.bid(0, { value: startingPrice });
      // error BidTooLow(uint256 paid, uint256 minBid);
      await expectRevert.unspecified(token.bid(0, { value: startingPrice }));
    });

    it("should refund the previous bidder", async function () {
      await token.bid(0, { value: startingPrice });

      const tracker = await balance.tracker(wallet0);
      await token.bid(0, {
        from: wallet1,
        value: startingPrice.add(startingPrice.mul(minimumPercentageIncreasex100).div(new BN(10000)))
      });
      const delta = await tracker.delta();
      expect(delta).to.bignumber.eq(startingPrice);
    });

    it("should save the new bid", async function () {
      const state0 = await token.getAuctionState();
      expect(state0.bidAmount).to.bignumber.eq("0");
      expect(state0.bidder).to.eq(constants.ZERO_ADDRESS);

      await token.bid(0, { value: startingPrice });
      const state1 = await token.getAuctionState();
      expect(state1.bidAmount).to.bignumber.eq(startingPrice);
      expect(state1.bidder).to.eq(wallet0);

      const newAmount = startingPrice.mul(new BN(2));
      await token.bid(0, { from: wallet1, value: newAmount });
      const state2 = await token.getAuctionState();
      expect(state2.bidAmount).to.bignumber.eq(newAmount);
      expect(state2.bidder).to.eq(wallet1);
    });

    it("should extend the auction duration after last-minute bids and emit an event", async function () {
      const state0 = await token.getAuctionState();
      await time.increaseTo(state0.endTime.sub(new BN(20)));
      const tx = await token.bid(0, { value: startingPrice });
      const state1 = await token.getAuctionState();
      expect(state1.endTime).to.bignumber.gt(state0.endTime);
      expect(state1.endTime).to.bignumber.eq(timeBuffer.add(await time.latest()));
      await expectEvent(tx, "AuctionExtended", { tokenId: "0", endTime: state1.endTime });
    });

    it("emits Bid event", async function () {
      const result = await token.bid(0, { value: startingPrice });
      await expectEvent(result, "Bid", { tokenId: "0", bidder: wallet0, amount: startingPrice });
    });
  });

  context("settling auctions", async function () {
    beforeEach("make a bid", async function () {
      await token.bid(0, { value: startingPrice });
    });

    it("should fail if the auction is not over yet", async function () {
      // error AuctionNotEnded(uint256 current, uint256 end);
      await expectRevert.unspecified(token.settleAuction());
    });

    it("should increase the total supply", async function () {
      const totalSupply0 = await token.totalSupply();
      await time.increase(auctionDuration);
      await token.settleAuction();
      const totalSupply1 = await token.totalSupply();
      expect(totalSupply1).to.bignumber.eq(totalSupply0.add(new BN(1)));
    });

    it("should mint the new token to the winner", async function () {
      await time.increase(auctionDuration);
      await token.settleAuction();
      const ownerOfToken = await token.ownerOf(0);
      expect(ownerOfToken).to.eq(wallet0);
    });

    it("should not mint a token if there were no bids", async function () {
      const anotherToken = await ERC721Auction.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        tokenMaxSupply,
        startingPrice,
        auctionDuration,
        timeBuffer,
        minimumPercentageIncreasex100,
        0,
        wallet0
      );
      await time.increase(auctionDuration);
      const totalSupply0 = await anotherToken.totalSupply();
      await anotherToken.settleAuction();
      const totalSupply1 = await anotherToken.totalSupply();
      expect(totalSupply1).to.bignumber.eq(totalSupply0);
      await expectRevert(anotherToken.ownerOf(0), "ERC721: owner query for nonexistent token");
    });

    it("should create a new auction, but only below maxSupply", async function () {
      await time.increase(auctionDuration);
      await token.settleAuction();
      const state0 = await token.getAuctionState();
      expect(state0.startTime).to.bignumber.eq(await time.latest());
      expect(state0.endTime).to.bignumber.eq(auctionDuration.add(new BN(state0.startTime)));
      expect(state0.bidAmount).to.bignumber.eq("0");
      expect(state0.bidder).to.eq(constants.ZERO_ADDRESS);

      await token.bid(1, { value: startingPrice.mul(new BN(2)) });
      await time.increase(auctionDuration);
      await token.settleAuction();
      const state1 = await token.getAuctionState();
      expect(state1.startTime).to.bignumber.eq(await time.latest());
      expect(state1.endTime).to.bignumber.eq(auctionDuration.add(new BN(state1.startTime)));
      expect(state1.bidAmount).to.bignumber.eq("0");
      expect(state1.bidder).to.eq(constants.ZERO_ADDRESS);

      await token.bid(2, { value: startingPrice.mul(new BN(3)) });
      await time.increase(auctionDuration);
      const state2 = await token.getAuctionState();
      await token.settleAuction();
      const state3 = await token.getAuctionState();
      expect(state3.startTime).to.bignumber.eq(state2.startTime);
      expect(state3.endTime).to.bignumber.eq(state2.endTime);
      expect(state3.bidAmount).to.bignumber.eq(state2.bidAmount);
      expect(state3.bidder).to.eq(state2.bidder);
    });

    it("should send the balance of the contract to the owner", async function () {
      await time.increase(auctionDuration);
      const contractTracker = await balance.tracker(token.address);
      const ownerTracker = await balance.tracker(wallet0);
      await token.settleAuction();
      const contractDelta = await contractTracker.delta();
      const { delta: ownerDelta, fees: ownerFees } = await ownerTracker.deltaWithFees();
      expect(contractDelta).to.bignumber.eq(startingPrice.mul(new BN(-1)));
      expect(ownerDelta).to.bignumber.eq(startingPrice.sub(ownerFees));
      expect(await balance.current(token.address)).to.bignumber.eq("0");
    });

    it("should emit AuctionSettled event", async function () {
      await time.increase(auctionDuration);
      const result = await token.settleAuction();
      await expectEvent(result, "AuctionSettled", { tokenId: "0", bidder: wallet0, amount: startingPrice });
    });
  });
});
