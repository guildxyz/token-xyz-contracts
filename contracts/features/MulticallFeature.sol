// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { FixinCommon } from "../fixins/FixinCommon.sol";
import { LibMigrate } from "../migrations/LibMigrate.sol";
import { IFeature } from "./interfaces/IFeature.sol";
import { Multicall } from "@openzeppelin/contracts/utils/Multicall.sol";

/// @title Provides a function to batch together multiple calls in a single external call.
contract MulticallFeature is IFeature, FixinCommon, Multicall {
    /// @notice Name of this feature.
    string public constant FEATURE_NAME = "Multicall";
    /// @notice Version of this feature.
    uint96 public immutable FEATURE_VERSION = _encodeVersion(1, 0, 0);

    /// @notice Initialize and register this feature. Should be delegatecalled by `Migrate.migrate()`.
    /// @return success `LibMigrate.SUCCESS` on success.
    function migrate() external returns (bytes4 success) {
        _registerFeatureFunction(this.multicall.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }
}
