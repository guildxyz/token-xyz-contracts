// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title Basic interface for a factory feature contract.
interface IFactoryFeature {
    /// @notice The data belonging to a specific deployed contract.
    /// @param factoryVersion The version number of the factory that was used to deploy the contract.
    /// @param contractAddress The address of the deployed contract.
    struct DeployData {
        uint96 factoryVersion;
        address contractAddress;
    }
}
