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

library LibBootstrap {
    /// @notice Magic bytes returned by the bootstrapper to indicate success.
    ///         This is `keccack('BOOTSTRAP_SUCCESS')`.
    bytes4 internal constant BOOTSTRAP_SUCCESS = 0xd150751b;

    /// @notice Error thrown when a delegatecall to a bootstrap function failed.
    /// @param target The address that was attempted to be called.
    /// @param resultData The result bytes of the call.
    error BootstrapCallFailed(address target, bytes resultData);

    /// @notice Perform a delegatecall and ensure it returns the magic bytes.
    /// @param target The call target.
    /// @param data The call data.
    function delegatecallBootstrapFunction(address target, bytes memory data) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory resultData) = target.delegatecall(data);
        if (!success || resultData.length != 32 || abi.decode(resultData, (bytes4)) != BOOTSTRAP_SUCCESS) {
            revert BootstrapCallFailed(target, resultData);
        }
    }
}
