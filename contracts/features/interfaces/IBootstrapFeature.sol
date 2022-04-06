// SPDX-License-Identifier: Apache-2.0

/*

    The file was modified by Agora.
    2022 agora.xyz

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

/// @title Detachable `bootstrap()` feature.
interface IBootstrapFeature {
    /// @notice Error thrown when the bootstrap() function is called by the wrong address.
    /// @param actualCaller The caller of the function.
    /// @param allowedCaller The address that is allowed to call the function.
    error InvalidBootstrapCaller(address actualCaller, address allowedCaller);

    /// @notice Error thrown when the die() function is called by the wrong address.
    /// @param actualCaller The caller of the function.
    /// @param deployer The deployer's address, which is allowed to call the function.
    error InvalidDieCaller(address actualCaller, address deployer);

    /// @notice Bootstrap the initial feature set of this contract by delegatecalling
    ///      into `target`. Before exiting the `bootstrap()` function will
    ///      deregister itself from the proxy to prevent being called again.
    /// @param target The bootstrapper contract address.
    /// @param callData The call data to execute on `target`.
    function bootstrap(address target, bytes calldata callData) external;
}
