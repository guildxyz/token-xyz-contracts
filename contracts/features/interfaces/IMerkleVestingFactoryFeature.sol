// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title A contract that deploys token vesting contracts for anyone.
interface IMerkleVestingFactoryFeature {
    /// @notice Deploys a new Merkle Vesting contract.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @param token The address of the token to distribute.
    /// @param owner The owner address of the contract to be deployed. Will have special access to some functions.
    function createVesting(
        string calldata urlName,
        address token,
        address owner
    ) external;

    /// @notice Returns all the deployed vesting contract addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return vestingAddresses The requested array of contract addresses.
    function getDeployedVestings(string calldata urlName) external view returns (address[] memory vestingAddresses);

    /// @notice Event emitted when creating a new vesting contract.
    /// @param deployer The address which created the vesting.
    /// @param urlName The urlName, where the created vesting contract is sorted in.
    /// @param instance The address of the newly created vesting contract.
    event MerkleVestingDeployed(address indexed deployer, string urlName, address instance);
}
