// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import { LibStorage } from "./LibStorage.sol";
import { IFactoryFeature } from "../features/interfaces/IFactoryFeature.sol";

/// @title Storage helpers for the `MerkleVestingFactory` feature.
library LibMerkleVestingFactoryStorage {
    /// @notice Storage bucket for this feature.
    struct Storage {
        // The data of deployments by entities.
        mapping(string => IFactoryFeature.DeployData[]) deploys;
    }

    /// @notice Get the storage bucket for this contract.
    /// @return stor The struct containing the state variables of the contract.
    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(LibStorage.StorageId.MerkleVestingFactory);
        // Dip into assembly to change the slot pointed to by the local variable `stor`.
        // solhint-disable-next-line max-line-length
        // See https://solidity.readthedocs.io/en/v0.8.14/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly {
            stor.slot := storageSlot
        }
    }
}
