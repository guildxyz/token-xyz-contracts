// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title A mintable NFT with auto-incrementing IDs.
contract ERC721AutoId is ERC721, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    uint256 public immutable maxSupply;
    string internal cid;
    Counters.Counter internal tokenIdCounter;

    error NonExistentToken(uint256 tokenId);
    error TokenIdOutOfBounds();

    constructor(
        string memory name,
        string memory symbol,
        string memory cid_,
        uint256 maxSupply_
    ) ERC721(name, symbol) {
        cid = cid_;
        maxSupply = maxSupply_;
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = tokenIdCounter.current();
        if (tokenId >= maxSupply) revert TokenIdOutOfBounds();
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken(tokenId);
        return string(abi.encodePacked("ipfs://", cid, "/", tokenId.toString(), ".json"));
    }

    function totalSupply() public view returns (uint256) {
        return tokenIdCounter.current();
    }
}
