// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./interfaces/IMerkleNFTMinterFactoryFeature.sol";
import "./deployables/MerkleNFTMinter.sol";
import "./deployables/MerkleNFTMinterAutoId.sol";
import "../fixins/FixinCommon.sol";
import "../storage/LibMerkleNFTMinterFactoryStorage.sol";
import "../migrations/LibMigrate.sol";
import "./interfaces/IFeature.sol";

/// @title A contract that deploys NFT Minter contracts for anyone.
contract MerkleNFTMinterFactoryFeature is IFeature, IMerkleNFTMinterFactoryFeature, FixinCommon {
    /// @notice Name of this feature.
    string public constant FEATURE_NAME = "MerkleNFTMinterFactory";
    /// @notice Version of this feature.
    uint96 public immutable FEATURE_VERSION = _encodeVersion(1, 0, 0);

    /// @notice Initialize and register this feature.
    ///      Should be delegatecalled by `Migrate.migrate()`.
    /// @return success `LibMigrate.SUCCESS` on success.
    function migrate() external returns (bytes4 success) {
        _registerFeatureFunction(this.createNFTMinter.selector);
        _registerFeatureFunction(this.getDeployedNFTMinters.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    /// @notice Deploys a new NFT Minter contract.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @param merkleRoot The root of the Merkle tree generated from the distribution list.
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
    ) external {
        address instance;
        if (specificIds) instance = address(new MerkleNFTMinter(merkleRoot, distributionDuration, nftMetadata, owner));
        else instance = address(new MerkleNFTMinterAutoId(merkleRoot, distributionDuration, nftMetadata, owner));
        LibMerkleNFTMinterFactoryStorage.getStorage().deploys[urlName].push(
            DeployData({factoryVersion: FEATURE_VERSION, contractAddress: instance})
        );
        emit MerkleNFTMinterDeployed(msg.sender, urlName, instance, FEATURE_VERSION);
    }

    /// @notice Returns all the deployed contract addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return minterAddresses The requested array of contract addresses.
    function getDeployedNFTMinters(string calldata urlName)
        external
        view
        returns (DeployData[] memory minterAddresses)
    {
        return LibMerkleNFTMinterFactoryStorage.getStorage().deploys[urlName];
    }
}
