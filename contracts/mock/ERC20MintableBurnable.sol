// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20MintableOwned } from "../features/deployables/token/ERC20/ERC20MintableOwned.sol";

/// @title A mintable and burnable ERC20 token with a single owner.
contract ERC20MintableBurnable is ERC20MintableOwned {
    // solhint-disable no-empty-blocks

    /// @notice Sets metadata, mints an initial supply and transfers ownership to `minter`.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @param tokenDecimals The number of decimals of the token.
    /// @param minter The address receiving the initial token supply that will also have permissions to mint it later.
    /// @param initialSupply The amount of pre-minted tokens.
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
