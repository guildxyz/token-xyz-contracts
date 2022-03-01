// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Common functions and events for a contract that deploys ERC20 token contracts for anyone.
interface ITokenFactoryBase {
    /// @notice Returns all the deployed token addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return tokenAddresses The requested array of token addresses.
    function getDeployedTokens(string calldata urlName) external view returns (address[] memory tokenAddresses);

    /// @notice Event emitted when creating a token.
    /// @param deployer The address which created the token.
    /// @param urlName The urlName, where the created token is sorted in.
    /// @param token The address of the newly created token.
    event TokenDeployed(address indexed deployer, string urlName, address token);
}
