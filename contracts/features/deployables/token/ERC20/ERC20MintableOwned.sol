// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ERC20InitialSupply } from "./ERC20InitialSupply.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/// @title A mintable ERC20 token with a single owner.
contract ERC20MintableOwned is ERC20InitialSupply, Ownable {
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
