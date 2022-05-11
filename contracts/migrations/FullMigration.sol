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

import "../TokenXyz.sol";
import "../features/interfaces/IOwnableFeature.sol";
import "../features/MulticallFeature.sol";
import "../features/TokenFactoryFeature.sol";
import "../features/TokenWithRolesFactoryFeature.sol";
import "../features/MerkleDistributorFactoryFeature.sol";
import "../features/MerkleVestingFactoryFeature.sol";
import "../features/ERC721MerkleDropFactoryFeature.sol";
import "../features/ERC721CurveFactoryFeature.sol";
import "./InitialMigration.sol";

/// @title A contract for deploying and configuring the full TokenXyz contract.
contract FullMigration {
    /// @notice Features to add the the proxy contract.
    struct Features {
        SimpleFunctionRegistryFeature registry;
        OwnableFeature ownable;
        MulticallFeature multicall;
        TokenFactoryFeature tokenFactory;
        TokenWithRolesFactoryFeature tokenWithRolesFactory;
        MerkleDistributorFactoryFeature merkleDistributorFactory;
        MerkleVestingFactoryFeature merkleVestingFactory;
        ERC721MerkleDropFactoryFeature erc721MerkleDropFactory;
        ERC721CurveFactoryFeature erc721CurveFactory;
    }

    /// @notice The allowed caller of `initializeTokenXyz()`.
    address public immutable initializeCaller;
    /// @notice The initial migration contract.
    InitialMigration private _initialMigration;

    /// @notice Instantiate this contract and set the allowed caller of `initializeTokenXyz()` to `initializeCaller`.
    /// @param initializeCaller_ The allowed caller of `initializeTokenXyz()`.
    constructor(address payable initializeCaller_) {
        initializeCaller = initializeCaller_;
        // Create an initial migration contract with this contract set to the allowed `initializeCaller`.
        _initialMigration = new InitialMigration(address(this));
    }

    /// @notice Retrieve the bootstrapper address to use when constructing `TokenXyz`.
    /// @return bootstrapper The bootstrapper address.
    function getBootstrapper() external view returns (address bootstrapper) {
        return address(_initialMigration);
    }

    /// @notice Initialize the `TokenXyz` contract with the full feature set,
    ///         transfer ownership to `owner`, then self-destruct.
    /// @param owner The owner of the contract.
    /// @param tokenXyz The instance of the TokenXyz contract. TokenXyz should
    ///        been constructed with this contract as the bootstrapper.
    /// @param features Features to add to the proxy.
    /// @return _tokenXyz The configured TokenXyz contract. Same as the `tokenXyz` parameter.
    function migrateTokenXyz(
        address payable owner,
        TokenXyz tokenXyz,
        Features memory features
    ) public returns (TokenXyz _tokenXyz) {
        require(msg.sender == initializeCaller, "FullMigration/INVALID_SENDER");

        // Perform the initial migration with the owner set to this contract.
        _initialMigration.initializeTokenXyz(
            payable(address(uint160(address(this)))),
            tokenXyz,
            InitialMigration.BootstrapFeatures({registry: features.registry, ownable: features.ownable})
        );

        // Add features.
        _addFeatures(tokenXyz, features);

        // Transfer ownership to the real owner.
        IOwnableFeature(address(tokenXyz)).transferOwnership(owner);

        // Self-destruct.
        this.die(owner);

        return tokenXyz;
    }

    /// @notice Destroy this contract. Only callable from ourselves (from `initializeTokenXyz()`).
    /// @param ethRecipient Receiver of any ETH in this contract.
    function die(address payable ethRecipient) external virtual {
        require(msg.sender == address(this), "FullMigration/INVALID_SENDER");
        // This contract should not hold any funds but we send
        // them to the ethRecipient just in case.
        selfdestruct(ethRecipient);
    }

    /// @notice Deploy and register features to the TokenXyz contract.
    /// @param tokenXyz The bootstrapped TokenXyz contract.
    /// @param features Features to add to the proxy.
    function _addFeatures(TokenXyz tokenXyz, Features memory features) private {
        IOwnableFeature ownable = IOwnableFeature(address(tokenXyz));
        // MulticallFeature
        {
            // Register the feature.
            ownable.migrate(
                address(features.multicall),
                abi.encodeWithSelector(MulticallFeature.migrate.selector),
                address(this)
            );
        }
        // TokenFactoryFeature
        {
            // Register the feature.
            ownable.migrate(
                address(features.tokenFactory),
                abi.encodeWithSelector(TokenFactoryFeature.migrate.selector),
                address(this)
            );
        }
        // TokenWithRolesFactoryFeature
        {
            // Register the feature.
            ownable.migrate(
                address(features.tokenWithRolesFactory),
                abi.encodeWithSelector(TokenWithRolesFactoryFeature.migrate.selector),
                address(this)
            );
        }
        // MerkleDistributorFactoryFeature
        {
            // Register the feature.
            ownable.migrate(
                address(features.merkleDistributorFactory),
                abi.encodeWithSelector(MerkleDistributorFactoryFeature.migrate.selector),
                address(this)
            );
        }
        // MerkleVestingFactoryFeature
        {
            // Register the feature.
            ownable.migrate(
                address(features.merkleVestingFactory),
                abi.encodeWithSelector(MerkleVestingFactoryFeature.migrate.selector),
                address(this)
            );
        }
        // ERC721MerkleDropFactoryFeature
        {
            // Register the feature.
            ownable.migrate(
                address(features.erc721MerkleDropFactory),
                abi.encodeWithSelector(ERC721MerkleDropFactoryFeature.migrate.selector),
                address(this)
            );
        }
        // ERC721CurveFactoryFeature
        {
            // Register the feature.
            ownable.migrate(
                address(features.erc721CurveFactory),
                abi.encodeWithSelector(ERC721CurveFactoryFeature.migrate.selector),
                address(this)
            );
        }
    }
}
