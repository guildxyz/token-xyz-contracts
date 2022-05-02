// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

/// @title Interface for an ownable NFT with capped supply.
interface IERC721CappedSupply is IERC721Metadata {
    /// @notice The maximum number of NFTs that can ever be minted.
    function maxSupply() external view returns (uint256);

    /// @notice The total amount of tokens stored by the contract.
    function totalSupply() external view returns (uint256);

    /// @notice Error thrown when trying to query info about a token that's not (yet) minted.
    /// @param tokenId The queried id.
    error NonExistentToken(uint256 tokenId);

    /// @notice Error thrown when the tokenId is higher the maximum supply.
    error TokenIdOutOfBounds();
}
