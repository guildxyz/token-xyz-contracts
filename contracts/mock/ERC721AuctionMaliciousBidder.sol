// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC721Auction } from "../features/deployables/interfaces/IERC721Auction.sol";

/// @title A bidder for ERC721Auction that cannot be outbid.
contract ERC721AuctionMaliciousBidder {
    IERC721Auction public auctionContract;

    constructor(IERC721Auction auction) {
        auctionContract = auction;
    }

    /// @notice Calls bid on the auction contract.
    /// @param tokenId The tokenId to bid on.
    function bid(uint256 tokenId) external payable {
        auctionContract.bid{ value: msg.value }(tokenId);
    }
}
