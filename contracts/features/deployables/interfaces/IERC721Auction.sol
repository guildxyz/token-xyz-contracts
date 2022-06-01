// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

/// @title An NFT distributed via on-chain bidding.
interface IERC721Auction is IERC721Metadata {
    /// @notice Struct storing the state of an auction.
    /// @param bidAmount The current highest bid amount.
    /// @param startTime The time when the auction started.
    /// @param endTime The time when the auction is scheduled to end.
    /// @param bidder The address of the current highest bidder.
    struct Auction {
        uint256 bidAmount;
        uint128 startTime;
        uint128 endTime;
        address bidder;
    }

    /// @notice Creates a bid for the specified token with the amount of ether sent along.
    /// @param tokenId The id of the token bid on.
    function bid(uint256 tokenId) external payable;

    /// @notice Sends the token to the highest bidder, mints the next one and transfers the fee to the owner.
    function settleAuction() external;

    /// @notice Sets a new startingPrice. Callable only by the owner.
    /// @param newValue The new value for startingPrice.
    function setStartingPrice(uint128 newValue) external;

    /// @notice Sets a new auctionDuration. Callable only by the owner.
    /// @param newValue The new value for auctionDuration.
    function setAuctionDuration(uint128 newValue) external;

    /// @notice Sets a new timeBuffer. Callable only by the owner.
    /// @param newValue The new value for timeBuffer.
    function setTimeBuffer(uint128 newValue) external;

    /// @notice Sets a new minimumPercentageIncreasex100. Callable only by the owner.
    /// @param newValue The new value for minimumPercentageIncreasex100.
    function setMinimumPercentageIncreasex100(uint128 newValue) external;

    /// @notice Returns the state of the current auction.
    /// @return tokenId The id of the token being bid on.
    /// @return bidder The address that made the last bid.
    /// @return bidAmount The amount the bidder offered.
    /// @return startTime The unix timestamp at which the current auction started.
    /// @return endTime The unix timestamp at which the current auction ends.
    function getAuctionState()
        external
        view
        returns (
            uint256 tokenId,
            address bidder,
            uint256 bidAmount,
            uint128 startTime,
            uint128 endTime
        );

    /// @notice The starting price of the tokens, i.e. the minimum amount of the first bid.
    /// @return The price in wei.
    function startingPrice() external view returns (uint128);

    /// @notice The duration of the auction of a specific token.
    function auctionDuration() external view returns (uint128);

    /// @notice The minimum time until an auction's end after a bid.
    function timeBuffer() external view returns (uint128);

    /// @notice The minimum percentage of the increase between the previous and the current bid, multiplied by 100.
    function minimumPercentageIncreasex100() external view returns (uint128);

    /// @notice The maximum number of NFTs that can ever be minted.
    function maxSupply() external view returns (uint256);

    /// @notice The total amount of tokens stored by the contract.
    function totalSupply() external view returns (uint256);

    /// @notice This event is triggered whenever a new auction is created.
    /// @param tokenId The id of the token to bid on.
    /// @param startTime The time that the auction is started.
    /// @param endTime The time that the auction is scheduled to end.
    event AuctionCreated(uint256 tokenId, uint256 startTime, uint256 endTime);

    /// @notice This event is triggered whenever the auctionDuration is changed.
    /// @param newValue The new value of auctionDuration.
    event AuctionDurationChanged(uint128 newValue);

    /// @notice This event is triggered whenever an auction's end time is extended.
    /// @param tokenId The id of the token being bid on.
    /// @param endTime The time that the auction is scheduled to end.
    event AuctionExtended(uint256 tokenId, uint256 endTime);

    /// @notice This event is triggered whenever a call to #settleAuction succeeds.
    /// @param tokenId The id of the token being bid on.
    /// @param bidder The address that received the tokens.
    /// @param amount The amount of tokens the address received.
    event AuctionSettled(uint256 tokenId, address bidder, uint256 amount);

    /// @notice This event is triggered whenever a call to #bid succeeds.
    /// @param tokenId The id of the token being bid on.
    /// @param bidder The address that received the tokens.
    /// @param amount The amount of tokens the address received.
    event Bid(uint256 tokenId, address bidder, uint256 amount);

    /// @notice This event is triggered whenever the minimumPercentageIncreasex100 is changed.
    /// @param newValue The new value of minimumPercentageIncreasex100.
    event MinimumPercentageIncreasex100Changed(uint128 newValue);

    /// @notice This event is triggered whenever the startingPrice is changed.
    /// @param newValue The new value of startingPrice.
    event StartingPriceChanged(uint128 newValue);

    /// @notice This event is triggered whenever the timeBuffer is changed.
    /// @param newValue The new value of timeBuffer.
    event TimeBufferChanged(uint128 newValue);

    /// @notice Error thrown when the auction ended.
    /// @param current The current timestamp.
    /// @param end The time when the auction ended.
    error AuctionEnded(uint256 current, uint256 end);

    /// @notice Error thrown when the auction has not ended yet.
    /// @param current The current timestamp.
    /// @param end The time when the auction ended.
    error AuctionNotEnded(uint256 current, uint256 end);

    /// @notice Error thrown when the auction has not started yet.
    /// @param current The current timestamp.
    /// @param start The time when the auction is starting.
    error AuctionNotStarted(uint256 current, uint256 start);

    /// @notice Error thrown when trying to place a bid for a different token than the latest.
    /// @param tokenId The id of the token bid on.
    /// @param currentAuctionId The id of the token actually being auctioned.
    error BidForAnotherToken(uint256 tokenId, uint256 currentAuctionId);

    /// @notice Error thrown when the transaction value is lower than the minimum accepted bid.
    /// @param paid The amount paid in wei.
    /// @param minBid The minimum accepted bid in wei.
    error BidTooLow(uint256 paid, uint256 minBid);

    /// @notice Error thrown when a function receives invalid parameters.
    error InvalidParameters();

    /// @notice Error thrown when the maximum supply attempted to be set is zero.
    error MaxSupplyZero();

    /// @notice Error thrown when trying to query info about a token that's not (yet) minted.
    /// @param tokenId The queried id.
    error NonExistentToken(uint256 tokenId);

    /// @notice Error thrown when the starting price attempted to be set is zero.
    error StartingPriceZero();

    /// @notice Error thrown when the tokenId is higher than the maximum supply.
    /// @param tokenId The id that was attempted to be used.
    /// @param maxSupply The maximum supply of the token.
    error TokenIdOutOfBounds(uint256 tokenId, uint256 maxSupply);
}
