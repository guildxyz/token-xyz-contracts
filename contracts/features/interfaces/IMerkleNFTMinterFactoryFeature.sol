// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../deployables/interfaces/IMerkleNFTMinter.sol";
import "./IFactoryFeature.sol";

/// @title A contract that deploys NFT minter contracts for anyone.
interface IMerkleNFTMinterFactoryFeature is IFactoryFeature {
    /// @notice Deploys a new NFT Minter contract.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @param merkleRoot The root of the merkle tree generated from the distribution list.
    /// @param distributionDuration The time interval while the distribution lasts in seconds.
    /// @param nftMetadata The basic metadata of the NFT that will be created.
    /// @param specificIds If true: the tokenIds, else: the amount of tokens per user will be specified.
    /// @param owner The owner address of the contract to be deployed. Will have special access to some functions.
    function createNFTMinter(
        string calldata urlName,
        bytes32 merkleRoot,
        uint256 distributionDuration,
        IMerkleNFTMinter.NftMetadata memory nftMetadata,
        bool specificIds,
        address owner
    ) external;

    /// @notice Returns all the deployed contract addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return minterAddresses The requested array of contract addresses.
    function getDeployedNFTMinters(string calldata urlName) external view returns (DeployData[] memory minterAddresses);

    /// @notice Event emitted when creating a new NFT Minter contract.
    /// @param deployer The address which created the NFT Minter.
    /// @param urlName The urlName, where the created NFT Minter contract is sorted in.
    /// @param instance The address of the newly created NFT Minter contract.
    /// @param factoryVersion The version number of the factory that was used to deploy the contract.
    event MerkleNFTMinterDeployed(address indexed deployer, string urlName, address instance, uint96 factoryVersion);
}
