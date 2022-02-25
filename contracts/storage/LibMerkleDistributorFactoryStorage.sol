// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "./LibStorage.sol";

/// @title Storage helpers for the `MerkleDistributorFactory` feature.
library LibMerkleDistributorFactoryStorage {
    /// @notice Storage bucket for this feature.
    struct Storage {
        // The addresses of deployments by entities
        mapping(string => address[]) deploys;
    }

    /// @notice Get the storage bucket for this contract.
    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(LibStorage.StorageId.MerkleDistributorFactory);
        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.8.12/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly {
            stor.slot := storageSlot
        }
    }
}
