// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title A contract that deploys token airdrop contracts for anyone.
interface IMerkleDistributorFactoryFeature {
    /// @notice Deploys a new Merkle Distributor contract.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @param token The address of the token to distribute.
    /// @param merkleRoot The root of the merkle tree generated from the distribution list.
    /// @param distributionDuration The time interval while the distribution lasts in seconds.
    /// @param owner The owner address of the contract to be deployed. Will have special access to some functions.
    function createAirdrop(
        string calldata urlName,
        address token,
        bytes32 merkleRoot,
        uint256 distributionDuration,
        address owner
    ) external;

    /// @notice Returns all the deployed airdrop contract addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return airdropAddresses The requested array of contract addresses.
    function getDeployedAirdrops(string calldata urlName) external view returns (address[] memory airdropAddresses);

    /// @notice Event emitted when creating a new airdrop contract.
    /// @param deployer The address which created the airdrop.
    /// @param urlName The urlName, where the created airdrop contract is sorted in.
    /// @param instance The address of the newly created airdrop contract.
    event MerkleDistributorDeployed(address indexed deployer, string urlName, address instance);
}
