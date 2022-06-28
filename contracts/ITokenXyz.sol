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

pragma solidity ^0.8.0;

import { IOwnableFeature } from "./features/interfaces/IOwnableFeature.sol";
import { ISimpleFunctionRegistryFeature } from "./features/interfaces/ISimpleFunctionRegistryFeature.sol";
import { IMulticallFeature } from "./features/interfaces/IMulticallFeature.sol";
import { ITokenFactoryFeature } from "./features/interfaces/ITokenFactoryFeature.sol";
import { ITokenWithRolesFactoryFeature } from "./features/interfaces/ITokenWithRolesFactoryFeature.sol";
import { IMerkleDistributorFactoryFeature } from "./features/interfaces/IMerkleDistributorFactoryFeature.sol";
import { IMerkleVestingFactoryFeature } from "./features/interfaces/IMerkleVestingFactoryFeature.sol";
import { IERC721MerkleDropFactoryFeature } from "./features/interfaces/IERC721MerkleDropFactoryFeature.sol";
import { IERC721CurveFactoryFeature } from "./features/interfaces/IERC721CurveFactoryFeature.sol";
import { IERC721AuctionFactoryFeature } from "./features/interfaces/IERC721AuctionFactoryFeature.sol";

/// @title Interface for a fully featured token.xyz proxy.
/// @dev The ABI of this contract should be used when interacting with the set of TokenXyz contracts.
interface ITokenXyz is
    IOwnableFeature,
    ISimpleFunctionRegistryFeature,
    IMulticallFeature,
    ITokenFactoryFeature,
    ITokenWithRolesFactoryFeature,
    IMerkleDistributorFactoryFeature,
    IMerkleVestingFactoryFeature,
    IERC721MerkleDropFactoryFeature,
    IERC721CurveFactoryFeature,
    IERC721AuctionFactoryFeature
{
    /// @notice Error thrown when the requested function is not found in any features.
    /// @param selector The function's selector that was attempted to be called.
    error NotImplemented(bytes4 selector);

    /// @notice Fallback for just receiving ether.
    receive() external payable;
}
