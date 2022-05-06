// SPDX-License-Identifier: GPL-3.0-or-later

/*

  The file has been modified.
  2022 token.xyz

*/

pragma solidity ^0.8.0;

/// @title Allows anyone to mint a non-fungible token if they exist in a Merkle root.
interface IMerkleNFTMinter {
    /// @notice The metadata of the NFT to be created.
    /// @notice The name of the NFT to be created.
    /// @notice The symbol of the NFT to be created.
    /// @notice The maximum number of the tokens that can be created.
    struct NftMetadata {
        string name;
        string symbol;
        string ipfsHash;
        uint256 maxSupply;
    }

    /// @notice Returns the address of the token distributed by this contract.
    function token() external view returns (address);

    /// @notice Returns the Merkle root of the Merkle tree containing account balances available to claim.
    function merkleRoot() external view returns (bytes32);

    /// @notice Returns the unix timestamp that marks the end of the token distribution.
    function distributionEnd() external view returns (uint256);

    /// @notice Claim the given amount of the token to the given address. Reverts if the inputs are invalid.
    /// @param index A value from the generated input list.
    /// @param account A value from the generated input list.
    /// @param amount A value from the generated input list.
    /// @param merkleProof A an array of values from the generated input list.
    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external;

    /// @notice Transfers the token's ownership to the owner after the distribution has ended or all tokens are claimed.
    /// @param recipient The address receiving the tokens.
    function withdraw(address recipient) external;

    /// @notice This event is triggered whenever a call to #claim succeeds.
    /// @param index A value from the generated input list.
    /// @param account A value from the generated input list.
    event Claimed(uint256 index, address account);

    /// @notice This event is triggered whenever a call to #withdraw succeeds.
    /// @param token The address of the token the address received.
    /// @param account The address that received the tokens.
    event Withdrawn(address token, address account);

    /// @notice Error thrown when the distribution period ended.
    /// @param current The current timestamp.
    /// @param end The time when the distribution ended.
    error DistributionEnded(uint256 current, uint256 end);

    /// @notice Error thrown when the distribution period did not end yet.
    /// @param current The current timestamp.
    /// @param end The time when the distribution ends.
    /// @param remainingNfts The number of NFTs unclaimed.
    error DistributionOngoing(uint256 current, uint256 end, uint256 remainingNfts);

    /// @notice Error thrown when the drop is already claimed.
    error DropClaimed();

    /// @notice Error thrown when a function receives invalid parameters.
    error InvalidParameters();

    /// @notice Error thrown when the Merkle proof is invalid.
    error InvalidProof();
}
