// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./ERC721AutoId.sol";

/// @title A mintable NFT with auto-incrementing IDs and a batchMint function.
contract ERC721AutoIdBatchMint is ERC721AutoId {
    using Counters for Counters.Counter;

    constructor(
        string memory name,
        string memory symbol,
        string memory cid_,
        uint256 maxSupply_
    ) ERC721AutoId(name, symbol, cid_, maxSupply_) {}

    function safeBatchMint(address to, uint256 amount) public onlyOwner {
        uint256 tokenId = tokenIdCounter.current();
        uint256 lastTokenId = tokenId + amount - 1;
        if (lastTokenId >= maxSupply) revert TokenIdOutOfBounds();
        for (; tokenId <= lastTokenId; ) {
            tokenIdCounter.increment();
            _safeMint(to, tokenId);
            unchecked {
                ++tokenId;
            }
        }
    }
}
