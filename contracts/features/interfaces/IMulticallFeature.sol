// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Provides a function to batch together multiple calls in a single external call.
interface IMulticallFeature {
    /// @notice Receives and executes a batch of function calls on this contract.
    /// @param data An array of the encoded function call data.
    /// @return results An array of the results of the individual function calls.
    function multicall(bytes[] calldata data) external returns (bytes[] memory results);
}
