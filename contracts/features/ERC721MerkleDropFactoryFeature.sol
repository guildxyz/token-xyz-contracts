// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./interfaces/IERC721MerkleDropFactoryFeature.sol";
import "./deployables/token/ERC721/ERC721MerkleDrop.sol";
import "./deployables/token/ERC721/ERC721BatchMerkleDrop.sol";
import "../fixins/FixinCommon.sol";
import "../storage/LibERC721MerkleDropFactoryStorage.sol";
import "../migrations/LibMigrate.sol";
import "./interfaces/IFeature.sol";

/// @title A contract that deploys NFTs with Merkle tree-based distribution for anyone.
contract ERC721MerkleDropFactoryFeature is IFeature, IERC721MerkleDropFactoryFeature, FixinCommon {
    /// @notice Name of this feature.
    string public constant FEATURE_NAME = "ERC721MerkleDropFactory";
    /// @notice Version of this feature.
    uint96 public immutable FEATURE_VERSION = _encodeVersion(1, 0, 0);

    /// @notice Initialize and register this feature. Should be delegatecalled by `Migrate.migrate()`.
    /// @return success `LibMigrate.SUCCESS` on success.
    function migrate() external returns (bytes4 success) {
        _registerFeatureFunction(this.createNFTMerkleDrop.selector);
        _registerFeatureFunction(this.getDeployedNFTMerkleDrops.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    /// @notice Deploys a new NFT Merkle Drop contract.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @param merkleRoot The root of the Merkle tree generated from the distribution list.
    /// @param distributionDuration The time interval while the distribution lasts in seconds.
    /// @param nftMetadata The basic metadata of the NFT that will be created.
    /// @param specificIds If true: the tokenIds, else: the amount of tokens per user will be specified.
    /// @param owner The owner address of the contract to be deployed. Will have special access to some functions.
    function createNFTMerkleDrop(
        string calldata urlName,
        bytes32 merkleRoot,
        uint256 distributionDuration,
        IERC721FactoryCommon.NftMetadata memory nftMetadata,
        bool specificIds,
        address owner
    ) external {
        address instance;
        if (specificIds)
            instance = address(
                new ERC721MerkleDrop(
                    nftMetadata.name,
                    nftMetadata.symbol,
                    nftMetadata.ipfsHash,
                    nftMetadata.maxSupply,
                    merkleRoot,
                    distributionDuration,
                    owner
                )
            );
        else
            instance = address(
                new ERC721BatchMerkleDrop(
                    nftMetadata.name,
                    nftMetadata.symbol,
                    nftMetadata.ipfsHash,
                    nftMetadata.maxSupply,
                    merkleRoot,
                    distributionDuration,
                    owner
                )
            );
        LibERC721MerkleDropFactoryStorage.getStorage().deploys[urlName].push(
            DeployData({factoryVersion: FEATURE_VERSION, contractAddress: instance})
        );
        emit ERC721MerkleDropDeployed(msg.sender, urlName, instance, FEATURE_VERSION);
    }

    /// @notice Returns all the deployed contract addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return nftAddresses The requested array of contract addresses.
    function getDeployedNFTMerkleDrops(string calldata urlName)
        external
        view
        returns (DeployData[] memory nftAddresses)
    {
        return LibERC721MerkleDropFactoryStorage.getStorage().deploys[urlName];
    }
}
