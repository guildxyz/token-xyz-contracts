// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ERC20InitialSupply } from "./ERC20InitialSupply.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/// @title A mintable ERC20 token.
contract ERC20MintableOwned is ERC20InitialSupply, Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint8 tokenDecimals,
        address minter,
        uint256 initialSupply
    ) ERC20InitialSupply(name, symbol, tokenDecimals, minter, initialSupply) {
        transferOwnership(minter);
    }

    /// @notice Mint an amount of tokens to an account.
    /// @param account The address of the account receiving the tokens.
    /// @param amount The amount of tokens the account receives.
    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }
}
