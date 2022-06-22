// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IMerkleDistributorFactoryFeature } from "./interfaces/IMerkleDistributorFactoryFeature.sol";
import { MerkleDistributor } from "./deployables/MerkleDistributor.sol";
import { FixinCommon } from "../fixins/FixinCommon.sol";
import { LibMerkleDistributorFactoryStorage } from "../storage/LibMerkleDistributorFactoryStorage.sol";
import { LibMigrate } from "../migrations/LibMigrate.sol";
import { IFeature } from "./interfaces/IFeature.sol";

/// @title A contract that deploys token airdrop contracts for anyone.
contract MerkleDistributorFactoryFeature is IFeature, IMerkleDistributorFactoryFeature, FixinCommon {
    /// @notice Name of this feature.
    string public constant FEATURE_NAME = "MerkleDistributorFactory";
    /// @notice Version of this feature.
    uint96 public immutable FEATURE_VERSION = _encodeVersion(1, 0, 0);

    /// @notice Initialize and register this feature. Should be delegatecalled by `Migrate.migrate()`.
    /// @return success `LibMigrate.SUCCESS` on success.
    function migrate() external returns (bytes4 success) {
        _registerFeatureFunction(this.createAirdrop.selector);
        _registerFeatureFunction(this.getDeployedAirdrops.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    /// @notice Deploys a new Merkle Distributor contract.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @param token The address of the token to distribute.
    /// @param merkleRoot The root of the Merkle tree generated from the distribution list.
    /// @param distributionDuration The time interval while the distribution lasts in seconds.
    /// @param owner The owner address of the contract to be deployed. Will have special access to some functions.
    function createAirdrop(
        string calldata urlName,
        address token,
        bytes32 merkleRoot,
        uint256 distributionDuration,
        address owner
    ) external {
        address instance = address(new MerkleDistributor(token, merkleRoot, distributionDuration, owner));
        LibMerkleDistributorFactoryStorage.getStorage().deploys[urlName].push(
            DeployData({ factoryVersion: FEATURE_VERSION, contractAddress: instance })
        );
        emit MerkleDistributorDeployed(msg.sender, urlName, instance, FEATURE_VERSION);
    }

    /// @notice Returns all the deployed airdrop contract addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return airdropAddresses The requested array of contract addresses.
    function getDeployedAirdrops(string calldata urlName) external view returns (DeployData[] memory airdropAddresses) {
        return LibMerkleDistributorFactoryStorage.getStorage().deploys[urlName];
    }
}
