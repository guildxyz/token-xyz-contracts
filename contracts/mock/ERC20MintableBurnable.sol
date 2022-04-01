// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../features/deployables/token/ERC20/ERC20MintableOwned.sol";

/// @title A mintable and burnable ERC20 token
contract ERC20MintableBurnable is ERC20MintableOwned {
    constructor(
        string memory name,
        string memory symbol,
        uint8 tokenDecimals,
        address minter,
        uint256 initialSupply
    ) ERC20MintableOwned(name, symbol, tokenDecimals, minter, initialSupply) {}

    /// @notice Burn an amount of tokens from an account
    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }
}
