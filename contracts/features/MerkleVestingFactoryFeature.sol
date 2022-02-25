// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./interfaces/IMerkleVestingFactoryFeature.sol";
import "./deployables/MerkleVesting.sol";
import "../fixins/FixinCommon.sol";
import "../storage/LibMerkleVestingFactoryStorage.sol";
import "../migrations/LibMigrate.sol";
import "./interfaces/IFeature.sol";

contract MerkleVestingFactoryFeature is IFeature, IMerkleVestingFactoryFeature, FixinCommon {
    /// @dev Name of this feature.
    string public constant override FEATURE_NAME = "MerkleVestingFactory";
    /// @dev Version of this feature.
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);

    /// @dev Initialize and register this feature.
    ///      Should be delegatecalled by `Migrate.migrate()`.
    /// @return success `LibMigrate.SUCCESS` on success.
    function migrate() external returns (bytes4 success) {
        _registerFeatureFunction(this.createVesting.selector);
        _registerFeatureFunction(this.getDeployedVestings.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    /// @notice Deploys a new Merkle Vesting contract.
    /// @param creatorId The id of the creator.
    /// @param token The address of the token to distribute.
    /// @param owner The owner address of the contract to be deployed. Will have special access to some functions.
    function createVesting(
        string calldata creatorId,
        address token,
        address owner
    ) external {
        address instance = address(new MerkleVesting(token, owner));
        LibMerkleVestingFactoryStorage.getStorage().deploys[creatorId].push(instance);
        emit MerkleVestingDeployed(instance);
    }

    /// @notice Returns all the deployed vesting contract addresses by a specific creator.
    /// @param creatorId The id of the creator.
    /// @return vestingAddresses The requested array of contract addresses.
    function getDeployedVestings(string calldata creatorId) external view returns (address[] memory vestingAddresses) {
        return LibMerkleVestingFactoryStorage.getStorage().deploys[creatorId];
    }
}
