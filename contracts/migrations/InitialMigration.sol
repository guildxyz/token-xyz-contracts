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

pragma solidity 0.8.17;

import { TokenXyz } from "../TokenXyz.sol";
import { IBootstrapFeature } from "../features/interfaces/IBootstrapFeature.sol";
import { SimpleFunctionRegistryFeature } from "../features/SimpleFunctionRegistryFeature.sol";
import { OwnableFeature } from "../features/OwnableFeature.sol";
import { LibBootstrap } from "./LibBootstrap.sol";

/// @title A contract for deploying and configuring a minimal TokenXyz contract.
contract InitialMigration {
    /// @notice Features to bootstrap into the the proxy contract.
    struct BootstrapFeatures {
        SimpleFunctionRegistryFeature registry;
        OwnableFeature ownable;
    }

    /// @notice The allowed caller of `initializeTokenXyz()`. In production, this would be the governor.
    address public immutable initializeCaller;
    /// @notice The real address of this contract.
    address private immutable _implementation;

    /// @notice Instantiate this contract and set the allowed caller of `initializeTokenXyz()` to `initializeCaller_`.
    /// @param initializeCaller_ The allowed caller of `initializeTokenXyz()`.
    constructor(address initializeCaller_) {
        initializeCaller = initializeCaller_;
        _implementation = address(this);
    }

    /// @notice Retrieve the bootstrapper address to use when constructing `TokenXyz`.
    /// @return bootstrapper The bootstrapper address.
    function getBootstrapper() external view returns (address bootstrapper) {
        return _implementation;
    }

    /// @notice Initialize the `TokenXyz` contract with the minimum feature set,
    ///         transfers ownership to `owner`, then self-destructs.
    ///         Only callable by `initializeCaller` set in the contstructor.
    /// @param owner The owner of the contract.
    /// @param tokenXyz The instance of the TokenXyz contract, constructed with this contract as the bootstrapper.
    /// @param features Features to bootstrap into the proxy.
    /// @return _tokenXyz The configured TokenXyz contract. Same as the `tokenXyz` parameter.
    function initializeTokenXyz(
        address payable owner,
        TokenXyz tokenXyz,
        BootstrapFeatures memory features
    ) public virtual returns (TokenXyz _tokenXyz) {
        // Must be called by the allowed initializeCaller.
        require(msg.sender == initializeCaller, "InitialMigration/INVALID_SENDER");

        // Bootstrap the initial feature set.
        IBootstrapFeature(address(tokenXyz)).bootstrap(
            address(this),
            abi.encodeWithSelector(this.bootstrap.selector, owner, features)
        );

        // Self-destruct. This contract should not hold any funds but we send
        // them to the owner just in case.
        this.die(owner);

        return tokenXyz;
    }

    /// @notice Sets up the initial state of the `TokenXyz` contract.
    ///         The `TokenXyz` contract will delegatecall into this function.
    /// @param owner The new owner of the TokenXyz contract.
    /// @param features Features to bootstrap into the proxy.
    /// @return success Magic bytes if successful.
    function bootstrap(address owner, BootstrapFeatures memory features) public virtual returns (bytes4 success) {
        // Deploy and migrate the initial features.
        // Order matters here.

        // Initialize Registry.
        LibBootstrap.delegatecallBootstrapFunction(
            address(features.registry),
            abi.encodeWithSelector(SimpleFunctionRegistryFeature.bootstrap.selector)
        );

        // Initialize OwnableFeature.
        LibBootstrap.delegatecallBootstrapFunction(
            address(features.ownable),
            abi.encodeWithSelector(OwnableFeature.bootstrap.selector)
        );

        // De-register `SimpleFunctionRegistryFeature._extendSelf`.
        SimpleFunctionRegistryFeature(address(this)).rollback(
            SimpleFunctionRegistryFeature._extendSelf.selector,
            address(0)
        );

        // Transfer ownership to the real owner.
        OwnableFeature(address(this)).transferOwnership(owner);

        success = LibBootstrap.BOOTSTRAP_SUCCESS;
    }

    /// @notice Self-destructs this contract. Only callable by this contract.
    /// @param ethRecipient Who to transfer outstanding ETH to.
    function die(address payable ethRecipient) public virtual {
        require(msg.sender == _implementation, "InitialMigration/INVALID_SENDER");
        selfdestruct(ethRecipient);
    }
}
