// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IERC721Metadata } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

/// @title Provides ERC721 token minting with access restricted based on a Merkle tree.
interface IERC721MerkleDrop is IERC721Metadata {
    /// @notice The maximum number of NFTs that can ever be minted.
    /// @return count The number of NFTs.
    function maxSupply() external view returns (uint256 count);

    /// @notice The total amount of tokens stored by the contract.
    /// @return count The number of NFTs.
    function totalSupply() external view returns (uint256 count);

    /// @notice Returns the Merkle root of the Merkle tree containing account balances available to claim.
    /// @return root The root hash of the Merkle tree.
    function merkleRoot() external view returns (bytes32 root);

    /// @notice Returns the unix timestamp that marks the end of the token distribution.
    /// @return unixSeconds The unix timestamp in seconds.
    function distributionEnd() external view returns (uint256 unixSeconds);

    /// @notice Claims tokens to the given address. Reverts if the inputs are invalid.
    /// @param index A value from the generated input list.
    /// @param account A value from the generated input list.
    /// @param amount A value from the generated input list.
    /// @param merkleProof An array of values from the generated input list.
    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external;

    /// @notice Error thrown when the distribution period ended.
    /// @param current The current timestamp.
    /// @param end The time when the distribution ended.
    error DistributionEnded(uint256 current, uint256 end);

    /// @notice Error thrown when the distribution period did not end yet.
    /// @param current The current timestamp.
    /// @param end The time when the distribution ends.
    error DistributionOngoing(uint256 current, uint256 end);

    /// @notice Error thrown when the token is already claimed.
    error AlreadyClaimed();

    /// @notice Error thrown when a function receives invalid parameters.
    error InvalidParameters();

    /// @notice Error thrown when the Merkle proof is invalid.
    error InvalidProof();

    /// @notice Error thrown when the maximum supply attempted to be set is zero.
    error MaxSupplyZero();

    /// @notice Error thrown when trying to query info about a token that's not (yet) minted.
    /// @param tokenId The queried id.
    error NonExistentToken(uint256 tokenId);

    /// @notice Error thrown when the tokenId is higher than the maximum supply.
    /// @param tokenId The id that was attempted to be used.
    /// @param maxSupply The maximum supply of the token.
    error TokenIdOutOfBounds(uint256 tokenId, uint256 maxSupply);
}
