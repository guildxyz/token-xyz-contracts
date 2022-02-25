// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title A contract that deploys token vesting contracts for anyone.
interface IMerkleVestingFactoryFeature {
    /// @notice Deploys a new Merkle Vesting contract.
    /// @param creatorId The id of the creator.
    /// @param token The address of the token to distribute.
    /// @param owner The owner address of the contract to be deployed. Will have special access to some functions.
    function createVesting(
        string calldata creatorId,
        address token,
        address owner
    ) external;

    /// @notice Returns all the deployed vesting contract addresses by a specific creator.
    /// @param creatorId The id of the creator.
    /// @return vestingAddresses The requested array of contract addresses.
    function getDeployedVestings(string calldata creatorId) external view returns (address[] memory vestingAddresses);

    /// @notice Event emitted when creating a new vesting contract.
    /// @param instance The address of the newly created vesting contract.
    event MerkleVestingDeployed(address instance);
}
