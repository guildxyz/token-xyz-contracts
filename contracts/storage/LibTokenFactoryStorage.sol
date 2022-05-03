// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./LibStorage.sol";
import "../features/interfaces/IFactoryFeature.sol";

/// @title Storage helpers for the `TokenFactory` feature.
library LibTokenFactoryStorage {
    /// @notice Storage bucket for this feature.
    struct Storage {
        // The data of deployments by entities.
        mapping(string => IFactoryFeature.DeployData[]) deploys;
    }

    /// @notice Get the storage bucket for this contract.
    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(LibStorage.StorageId.TokenFactory);
        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.8.13/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly {
            stor.slot := storageSlot
        }
    }
}
