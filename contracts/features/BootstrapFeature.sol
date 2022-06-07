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

import { LibBootstrap } from "../migrations/LibBootstrap.sol";
import { LibProxyStorage } from "../storage/LibProxyStorage.sol";
import { IBootstrapFeature } from "./interfaces/IBootstrapFeature.sol";

/// @title Detachable `bootstrap()` feature.
contract BootstrapFeature is IBootstrapFeature {
    /// @notice The main proxy contract.
    ///         This has to be immutable to persist across delegatecalls.
    address private immutable _deployer;
    /// @notice The implementation address of this contract.
    ///         This has to be immutable to persist across delegatecalls.
    address private immutable _implementation;
    /// @notice The deployer.
    ///         This has to be immutable to persist across delegatecalls.
    address private immutable _bootstrapCaller;

    /// @notice Construct this contract and set the bootstrap migration contract.
    ///         After constructing this contract, `bootstrap()` should be called
    ///         to seed the initial feature set.
    /// @param bootstrapCaller The allowed caller of `bootstrap()`.
    constructor(address bootstrapCaller) {
        _deployer = msg.sender;
        _implementation = address(this);
        _bootstrapCaller = bootstrapCaller;
    }

    /// @notice Bootstrap the initial feature set of this contract by delegatecalling
    ///         into `target`. Before exiting the `bootstrap()` function will
    ///         deregister itself from the proxy to prevent being called again.
    /// @param target The bootstrapper contract address.
    /// @param callData The call data to execute on `target`.
    function bootstrap(address target, bytes calldata callData) external override {
        // Only the bootstrap caller can call this function.
        if (msg.sender != _bootstrapCaller) revert InvalidBootstrapCaller(msg.sender, _bootstrapCaller);

        // Deregister.
        LibProxyStorage.getStorage().impls[this.bootstrap.selector] = address(0);
        // Self-destruct.
        BootstrapFeature(_implementation).die();
        // Call the bootstrapper.
        LibBootstrap.delegatecallBootstrapFunction(target, callData);
    }

    /// @notice Self-destructs this contract. Can only be called by the deployer.
    function die() external {
        assert(address(this) == _implementation);
        if (msg.sender != _deployer) revert InvalidDieCaller(msg.sender, _deployer);
        selfdestruct(payable(msg.sender));
    }
}
