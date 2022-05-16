// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title MaxSupply-related functions and errors.
interface IERC20MaxSupply is IERC20Metadata {
    function maxSupply() external returns (uint256);

    /// @notice Error thrown when the max supply is attempted to be set lower than the initial supply.
    /// @param maxSupply The desired max supply.
    /// @param initialSupply The desired initial supply, that cannot be higher than the max.
    error MaxSupplyTooLow(uint256 maxSupply, uint256 initialSupply);

    /// @notice Error thrown when more tokens are attempted to be minted than the max supply.
    /// @param amount The amount of tokens attempted to be minted.
    /// @param currentSupply The current supply of the token.
    /// @param maxSupply The max supply of the token.
    error MaxSupplyExceeded(uint256 amount, uint256 currentSupply, uint256 maxSupply);
}
