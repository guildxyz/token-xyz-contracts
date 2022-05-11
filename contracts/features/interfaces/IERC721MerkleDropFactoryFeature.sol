// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IFactoryFeature.sol";
import "./IERC721FactoryCommon.sol";

/// @title A contract that deploys NFTs with Merkle tree-based distribution for anyone.
interface IERC721MerkleDropFactoryFeature is IFactoryFeature {
    /// @notice Deploys a new NFT Merkle Drop contract.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @param merkleRoot The root of the Merkle tree generated from the distribution list.
    /// @param distributionDuration The time interval while the distribution lasts in seconds.
    /// @param nftMetadata The basic metadata of the NFT that will be created (name, symbol, ipfsHash, maxSupply).
    /// @param specificIds If true: the tokenIds, else: the amount of tokens per user will be specified.
    /// @param owner The owner address of the contract to be deployed. Will have special access to some functions.
    function createNFTMerkleDrop(
        string calldata urlName,
        bytes32 merkleRoot,
        uint256 distributionDuration,
        IERC721FactoryCommon.NftMetadata memory nftMetadata,
        bool specificIds,
        address owner
    ) external;

    /// @notice Returns all the deployed contract addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return nftAddresses The requested array of contract addresses.
    function getDeployedNFTMerkleDrops(string calldata urlName)
        external
        view
        returns (DeployData[] memory nftAddresses);

    /// @notice Event emitted when creating a new NFT Merkle Drop contract.
    /// @param deployer The address which created the NFT contract.
    /// @param urlName The urlName, where the created NFT contract is sorted in.
    /// @param instance The address of the newly created NFT contract.
    /// @param factoryVersion The version number of the factory that was used to deploy the contract.
    event ERC721MerkleDropDeployed(address indexed deployer, string urlName, address instance, uint96 factoryVersion);
}
