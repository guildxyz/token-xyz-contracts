// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IFactoryFeature } from "./IFactoryFeature.sol";

/// @title Common functions and events for a contract that deploys ERC20 token contracts for anyone.
interface ITokenFactoryBase is IFactoryFeature {
    /// @notice Returns all the deployed token addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return tokenAddresses The requested array of token addresses.
    function getDeployedTokens(string calldata urlName) external view returns (DeployData[] memory tokenAddresses);

    /// @notice Event emitted when creating a token.
    /// @dev The deployer and factoryversion params are 0 if the token was added manually.
    /// @param deployer The address which created the token.
    /// @param urlName The urlName, where the created token is sorted in.
    /// @param token The address of the newly created token.
    /// @param factoryVersion The version number of the factory that was used to deploy the contract.
    event TokenAdded(address indexed deployer, string urlName, address token, uint96 factoryVersion);

    /// @notice Error thrown when the max supply is attempted to be set lower than the initial supply.
    /// @param maxSupply The desired max supply.
    /// @param initialSupply The desired initial supply, that cannot be higher than the max.
    error MaxSupplyTooLow(uint256 maxSupply, uint256 initialSupply);
}
