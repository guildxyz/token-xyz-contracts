// SPDX-License-Identifier: Apache-2.0

/*

  The file has been modified.
  2022 token.xyz

*/

/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.8.14;

import "../fixins/FixinCommon.sol";
import "../storage/LibOwnableStorage.sol";
import "../migrations/LibBootstrap.sol";
import "../migrations/LibMigrate.sol";
import "./interfaces/IFeature.sol";
import "./interfaces/IOwnableFeature.sol";
import "./SimpleFunctionRegistryFeature.sol";

/// @title Owner management features.
contract OwnableFeature is IFeature, IOwnableFeature, FixinCommon {
    /// @notice Name of this feature.
    string public constant FEATURE_NAME = "Ownable";
    /// @notice Version of this feature.
    uint96 public immutable FEATURE_VERSION = _encodeVersion(1, 0, 0);

    /// @notice Initializes this feature. The intial owner will be set to this (TokenXyz)
    ///         to allow the bootstrappers to call `extend()`. Ownership should be
    ///         transferred to the real owner by the bootstrapper after
    ///         bootstrapping is complete.
    /// @return success Magic bytes if successful.
    function bootstrap() external returns (bytes4 success) {
        // Set the owner to ourselves to allow bootstrappers to call `extend()`.
        LibOwnableStorage.getStorage().owner = address(this);

        // Register feature functions.
        SimpleFunctionRegistryFeature(address(this))._extendSelf(this.transferOwnership.selector, _implementation);
        SimpleFunctionRegistryFeature(address(this))._extendSelf(this.owner.selector, _implementation);
        SimpleFunctionRegistryFeature(address(this))._extendSelf(this.migrate.selector, _implementation);
        return LibBootstrap.BOOTSTRAP_SUCCESS;
    }

    /// @notice Change the owner of this contract. Only directly callable by the owner.
    /// @param newOwner New owner address.
    function transferOwnership(address newOwner) external override onlyOwner {
        LibOwnableStorage.Storage storage proxyStor = LibOwnableStorage.getStorage();

        if (newOwner == address(0)) {
            revert TransferOwnerToZero();
        } else {
            proxyStor.owner = newOwner;
            emit OwnershipTransferred(msg.sender, newOwner);
        }
    }

    /// @notice Execute a migration function in the context of the TokenXyz contract.
    ///         The result of the function being called should be the magic bytes
    ///         0x2c64c5ef (`keccack('MIGRATE_SUCCESS')`). Only callable by the owner.
    ///         Temporarily sets the owner to ourselves so we can perform admin functions.
    ///         Before returning, the owner will be set to `newOwner`.
    /// @param target The migrator contract address.
    /// @param data The call data.
    /// @param newOwner The address of the new owner.
    function migrate(
        address target,
        bytes calldata data,
        address newOwner
    ) external override onlyOwner {
        if (newOwner == address(0)) revert TransferOwnerToZero();

        LibOwnableStorage.Storage storage stor = LibOwnableStorage.getStorage();
        // The owner will be temporarily set to `address(this)` inside the call.
        stor.owner = address(this);

        // Perform the migration.
        LibMigrate.delegatecallMigrateFunction(target, data);

        // Update the owner.
        stor.owner = newOwner;

        emit Migrated(msg.sender, target, newOwner);
    }

    /// @notice Get the owner of this contract.
    /// @return owner_ The owner of this contract.
    function owner() external view override returns (address owner_) {
        return LibOwnableStorage.getStorage().owner;
    }
}
