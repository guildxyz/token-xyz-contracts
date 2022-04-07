// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A mintable NFT.
contract ERC721Mintable is ERC721, Ownable {
    using Strings for uint256;

    uint256 public immutable maxSupply;
    uint256 public totalSupply;
    string internal cid;

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

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        if (tokenId >= maxSupply) revert TokenIdOutOfBounds();
        totalSupply++;
        _safeMint(to, tokenId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken(tokenId);
        return string(abi.encodePacked("ipfs://", cid, "/", tokenId.toString(), ".json"));
    }
}
