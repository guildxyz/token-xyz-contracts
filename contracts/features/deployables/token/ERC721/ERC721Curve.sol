// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

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

    uint256 public immutable maxSupply;
    uint256 public immutable startingPrice;
    string internal cid;
    Counters.Counter internal tokenIdCounter;

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

    function getPriceOf(uint256 tokenId) public view returns (uint256) {
        if (tokenId >= maxSupply) revert TokenIdOutOfBounds(tokenId, maxSupply);
        return (startingPrice * maxSupply**2) / ((maxSupply - tokenId)**2);
    }

    function claim(address payable to) external payable {
        uint256 tokenId = tokenIdCounter.current();
        uint256 nextPrice = getPriceOf(tokenId);
        if (msg.value < nextPrice) revert PriceTooLow(msg.value, nextPrice);
        if (msg.value > nextPrice) to.sendEther(msg.value - nextPrice);

        tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function withdraw(address payable recipient) external onlyOwner {
        uint256 amount = address(this).balance;
        recipient.sendEther(amount);
        emit Withdrawn(recipient, amount);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, IERC721Metadata) returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken(tokenId);
        return string(abi.encodePacked("ipfs://", cid, "/", tokenId.toString(), ".json"));
    }

    function totalSupply() public view returns (uint256) {
        return tokenIdCounter.current();
    }
}
