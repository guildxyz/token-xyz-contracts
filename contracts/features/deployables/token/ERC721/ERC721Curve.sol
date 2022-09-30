// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { LibAddress } from "../../lib/LibAddress.sol";
import { IERC721Curve } from "../../interfaces/IERC721Curve.sol";
import { IERC721Metadata } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

/// @title An NFT with an ever increasing price along a curve.
contract ERC721Curve is IERC721Curve, ERC721, Ownable {
    using Counters for Counters.Counter;
    using LibAddress for address payable;
    using Strings for uint256;

    /// @inheritdoc IERC721Curve
    uint256 public immutable maxSupply;
    /// @inheritdoc IERC721Curve
    uint256 public immutable startingPrice;
    string internal cid;
    Counters.Counter internal tokenIdCounter;

    /// @notice Sets metadata, config and transfers ownership to `owner`.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @param cid_ The ipfs hash, under which the off-chain metadata is uploaded.
    /// @param maxSupply_ The maximum number of NFTs that can ever be minted.
    /// @param startingPrice_ The price of the first token in wei.
    /// @param owner The owner address: will be able to withdraw collected fees.
    constructor(
        string memory name,
        string memory symbol,
        string memory cid_,
        uint256 maxSupply_,
        uint256 startingPrice_,
        address owner
    ) ERC721(name, symbol) {
        if (maxSupply_ == 0) revert MaxSupplyZero();
        if (startingPrice_ == 0) revert StartingPriceZero();
        if (owner == address(0)) revert InvalidParameters();
        cid = cid_;
        maxSupply = maxSupply_;
        startingPrice = startingPrice_;
        _transferOwnership(owner);
    }

    /// @inheritdoc IERC721Curve
    function getPriceOf(uint256 tokenId) public view returns (uint256 price) {
        if (tokenId >= maxSupply) revert TokenIdOutOfBounds(tokenId, maxSupply);
        return (startingPrice * maxSupply**2) / ((maxSupply - tokenId)**2);
    }

    /// @inheritdoc IERC721Curve
    function claim(address payable to) external payable {
        uint256 tokenId = tokenIdCounter.current();
        uint256 nextPrice = getPriceOf(tokenId);
        if (msg.value < nextPrice) revert PriceTooLow(msg.value, nextPrice);
        if (msg.value > nextPrice) to.sendEther(msg.value - nextPrice);

        tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    /// @inheritdoc IERC721Curve
    function withdraw(address payable recipient) external onlyOwner {
        uint256 amount = address(this).balance;
        recipient.sendEther(amount);
        emit Withdrawn(recipient, amount);
    }

    /// @inheritdoc IERC721Metadata
    /// @param tokenId The id of the token.
    function tokenURI(uint256 tokenId) public view override(ERC721, IERC721Metadata) returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken(tokenId);
        return string.concat("ipfs://", cid, "/", tokenId.toString(), ".json");
    }

    /// @inheritdoc IERC721Curve
    function totalSupply() public view returns (uint256 count) {
        return tokenIdCounter.current();
    }
}
