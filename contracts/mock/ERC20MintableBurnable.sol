// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20MintableOwned } from "../features/deployables/token/ERC20/ERC20MintableOwned.sol";

/// @title A mintable and burnable ERC20 token.
contract ERC20MintableBurnable is ERC20MintableOwned {
    // solhint-disable no-empty-blocks

    constructor(
        string memory name,
        string memory symbol,
        uint8 tokenDecimals,
        address minter,
        uint256 initialSupply
    ) ERC20MintableOwned(name, symbol, tokenDecimals, minter, initialSupply) {}

    /// @notice Burn `amount` of tokens from `account`.
    /// @param account The address of the account to burn tokens from.
    /// @param amount The amount of tokens to burn in wei.
    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }
}
