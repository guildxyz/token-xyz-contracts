// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "../../lib/LibAddress.sol";
import "../../interfaces/IERC721Auction.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title An NFT distributed via on-chain bidding.
contract ERC721Auction is IERC721Auction, ERC721, Ownable {
    using Counters for Counters.Counter;
    using LibAddress for address payable;
    using Strings for uint256;

    // Auction properties
    AuctionConfig internal auctionConfig;
    AuctionState internal auctionState;

    // Token properties
    uint256 public immutable maxSupply;
    uint256 public totalSupply;
    string internal cid;
    Counters.Counter internal tokenIdCounter;

    /// @dev If startTime is 0, block.timestamp will be used.
    constructor(
        string memory name,
        string memory symbol,
        string memory cid_,
        uint256 maxSupply_,
        AuctionConfig memory config_,
        uint128 startTime,
        address owner
    ) ERC721(name, symbol) {
        if (maxSupply_ == 0) revert MaxSupplyZero();
        if (config_.startingPrice == 0) revert StartingPriceZero();
        if (config_.auctionDuration == 0 || owner == address(0)) revert InvalidParameters();

        auctionConfig.startingPrice = config_.startingPrice;
        auctionConfig.auctionDuration = config_.auctionDuration;
        auctionConfig.timeBuffer = config_.timeBuffer;
        auctionConfig.minimumPercentageIncreasex100 = config_.minimumPercentageIncreasex100;

        maxSupply = maxSupply_;
        cid = cid_;

        _createAuction(0, startTime == 0 ? uint128(block.timestamp) : startTime);

        _transferOwnership(owner);
    }

    function bid(uint256 tokenId) external payable {
        // Note: where condition is mostly false creating a local variable wouldn't save gas for most users.

        // Check tokenId.
        if (tokenId >= maxSupply) revert TokenIdOutOfBounds(tokenId, maxSupply);
        if (tokenIdCounter.current() != tokenId) revert BidForAnotherToken(tokenId, tokenIdCounter.current());

        // Check if the auction is currently running.
        uint128 auctionEndTime = auctionState.endTime;
        if (block.timestamp < auctionState.startTime) revert AuctionNotStarted(block.timestamp, auctionState.startTime);
        if (block.timestamp >= auctionEndTime) revert AuctionEnded(block.timestamp, auctionEndTime);

        // Check the amount offered.
        uint256 bidAmount = auctionState.bidAmount;
        uint256 minimumBid = bidAmount + ((bidAmount * auctionConfig.minimumPercentageIncreasex100) / 10000);
        if (msg.value < minimumBid) revert BidTooLow(msg.value, minimumBid);
        if (minimumBid == 0 && msg.value < auctionConfig.startingPrice)
            revert BidTooLow(msg.value, auctionConfig.startingPrice);

        // Refund the previous bidder.
        address lastBidder = auctionState.bidder;
        if (lastBidder != address(0)) payable(lastBidder).sendEther(bidAmount);

        // Save the new bid.
        auctionState.bidAmount = msg.value;
        auctionState.bidder = payable(msg.sender);

        // Extend the auction duration if we receive a bid in the last minutes.
        uint128 timeBuffer = auctionConfig.timeBuffer;
        if (auctionEndTime - block.timestamp < timeBuffer) {
            auctionEndTime = uint128(block.timestamp) + timeBuffer;
            auctionState.endTime = auctionEndTime;
            emit AuctionExtended(tokenId, auctionEndTime);
        }

        emit Bid(tokenId, msg.sender, msg.value);
    }

    function settleAuction() external {
        if (auctionState.endTime > block.timestamp) revert AuctionNotEnded(block.timestamp, auctionState.endTime);

        address winner = auctionState.bidder;
        uint256 bidAmount = auctionState.bidAmount;
        uint256 tokenId = tokenIdCounter.current();

        // Mint the token to the winner and pay out the owner.
        if (winner != address(0)) {
            _safeMint(winner, tokenId);

            // Send the contract's whole balance to the owner so there's no leftover in any case.
            payable(owner()).sendEther(address(this).balance);
        }

        // Create a new auction.
        _createAuction(tokenId + 1, uint128(block.timestamp));

        emit AuctionSettled(tokenId, winner, bidAmount);
    }

    function setStartingPrice(uint128 newValue) external onlyOwner {
        if (newValue == 0) revert StartingPriceZero();
        auctionConfig.startingPrice = newValue;
        emit StartingPriceChanged(newValue);
    }

    function setAuctionDuration(uint128 newValue) external onlyOwner {
        if (newValue == 0) revert InvalidParameters();
        auctionConfig.auctionDuration = newValue;
        emit AuctionDurationChanged(newValue);
    }

    function setTimeBuffer(uint128 newValue) external onlyOwner {
        auctionConfig.timeBuffer = newValue;
        emit TimeBufferChanged(newValue);
    }

    function setMinimumPercentageIncreasex100(uint128 newValue) external onlyOwner {
        auctionConfig.minimumPercentageIncreasex100 = newValue;
        emit MinimumPercentageIncreasex100Changed(newValue);
    }

    // Create a new auction if possible and emit an event.
    function _createAuction(uint256 nextTokenId, uint128 startTime) internal {
        if (nextTokenId < maxSupply) {
            uint128 endTime = startTime + auctionConfig.auctionDuration;
            auctionState = AuctionState({bidAmount: 0, startTime: startTime, endTime: endTime, bidder: address(0)});
            emit AuctionCreated(nextTokenId, startTime, endTime);
        }
    }

    function _safeMint(address to, uint256 tokenId) internal override {
        if (tokenId >= maxSupply) revert TokenIdOutOfBounds(tokenId, maxSupply);
        tokenIdCounter.increment();
        ++totalSupply;
        _safeMint(to, tokenId, "");
    }

    function getAuctionConfig()
        external
        view
        returns (
            uint128 startingPrice,
            uint128 auctionDuration,
            uint128 timeBuffer,
            uint128 minimumPercentageIncreasex100
        )
    {
        return (
            auctionConfig.startingPrice,
            auctionConfig.auctionDuration,
            auctionConfig.timeBuffer,
            auctionConfig.minimumPercentageIncreasex100
        );
    }

    function getAuctionState()
        external
        view
        returns (
            uint256 tokenId,
            address bidder,
            uint256 bidAmount,
            uint128 startTime,
            uint128 endTime
        )
    {
        return (
            tokenIdCounter.current(),
            auctionState.bidder,
            auctionState.bidAmount,
            auctionState.startTime,
            auctionState.endTime
        );
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, IERC721Metadata) returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken(tokenId);
        return string(abi.encodePacked("ipfs://", cid, "/", tokenId.toString(), ".json"));
    }
}