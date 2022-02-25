// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title A contract that deploys token airdrop contracts for anyone.
interface IMerkleDistributorFactoryFeature {
    /// @notice Deploys a new Merkle Distributor contract.
    /// @param creatorId The id of the creator.
    /// @param token The address of the token to distribute.
    /// @param merkleRoot The root of the merkle tree generated from the distribution list.
    /// @param distributionDuration The time interval while the distribution lasts in seconds.
    /// @param owner The owner address of the contract to be deployed. Will have special access to some functions.
    function createAirdrop(
        string calldata creatorId,
        address token,
        bytes32 merkleRoot,
        uint256 distributionDuration,
        address owner
    ) external;

    /// @notice Event emitted when creating a new airdrop contract.
    /// @param instance The address of the newly created airdrop contract.
    event MerkleDistributorDeployed(address instance);
}
