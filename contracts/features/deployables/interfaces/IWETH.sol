// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Interface for WETH.
interface IWETH is IERC20 {
    /// @notice Deposit ether to get wrapped ether.
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether.
    /// @param wad The amount of ether to withdraw.
    function withdraw(uint256 wad) external;
}
