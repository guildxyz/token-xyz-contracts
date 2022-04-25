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

pragma solidity 0.8.13;

import "./LibStorage.sol";

/// @title Storage helpers for the `SimpleFunctionRegistry` feature.
library LibSimpleFunctionRegistryStorage {
    /// @notice Storage bucket for this feature.
    struct Storage {
        // Mapping of function selector -> implementation history.
        mapping(bytes4 => address[]) implHistory;
    }

    /// @notice Get the storage bucket for this contract.
    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(LibStorage.StorageId.SimpleFunctionRegistry);
        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.8.13/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly {
            stor.slot := storageSlot
        }
    }
}
