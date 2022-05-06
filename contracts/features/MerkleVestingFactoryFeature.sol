// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./interfaces/IMerkleVestingFactoryFeature.sol";
import "./deployables/MerkleVesting.sol";
import "../fixins/FixinCommon.sol";
import "../storage/LibMerkleVestingFactoryStorage.sol";
import "../migrations/LibMigrate.sol";
import "./interfaces/IFeature.sol";

/// @title A contract that deploys token vesting contracts for anyone.
contract MerkleVestingFactoryFeature is IFeature, IMerkleVestingFactoryFeature, FixinCommon {
    /// @notice Name of this feature.
    string public constant FEATURE_NAME = "MerkleVestingFactory";
    /// @notice Version of this feature.
    uint96 public immutable FEATURE_VERSION = _encodeVersion(1, 0, 0);

    /// @notice Initialize and register this feature. Should be delegatecalled by `Migrate.migrate()`.
    /// @return success `LibMigrate.SUCCESS` on success.
    function migrate() external returns (bytes4 success) {
        _registerFeatureFunction(this.createVesting.selector);
        _registerFeatureFunction(this.getDeployedVestings.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    /// @notice Deploys a new Merkle Vesting contract.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @param token The address of the token to distribute.
    /// @param owner The owner address of the contract to be deployed. Will have special access to some functions.
    function createVesting(
        string calldata urlName,
        address token,
        address owner
    ) external {
        address instance = address(new MerkleVesting(token, owner));
        LibMerkleVestingFactoryStorage.getStorage().deploys[urlName].push(
            DeployData({factoryVersion: FEATURE_VERSION, contractAddress: instance})
        );
        emit MerkleVestingDeployed(msg.sender, urlName, instance, FEATURE_VERSION);
    }

    /// @notice Returns all the deployed vesting contract addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return vestingAddresses The requested array of contract addresses.
    function getDeployedVestings(string calldata urlName) external view returns (DeployData[] memory vestingAddresses) {
        return LibMerkleVestingFactoryStorage.getStorage().deploys[urlName];
    }
}
