// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ERC20InitialSupply } from "./ERC20InitialSupply.sol";
import { IERC20MaxSupply } from "../../interfaces/IERC20MaxSupply.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/// @title A mintable ERC20 token with a single owner and capped supply.
contract ERC20MintableOwnedMaxSupply is IERC20MaxSupply, ERC20InitialSupply, Ownable {
    /// @inheritdoc IERC20MaxSupply
    uint256 public immutable maxSupply;

    /// @notice Sets metadata, mints an initial supply and transfers ownership to `minter`.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @param tokenDecimals The number of decimals of the token.
    /// @param minter The address receiving the initial token supply that will also have permissions to mint it later.
    /// @param initialSupply The amount of pre-minted tokens.
    /// @param maxSupply_ The maximum amount of tokens that can ever exist.
    constructor(
        string memory name,
        string memory symbol,
        uint8 tokenDecimals,
        address minter,
        uint256 initialSupply,
        uint256 maxSupply_
    ) ERC20InitialSupply(name, symbol, tokenDecimals, minter, initialSupply) {
        if (maxSupply_ < initialSupply) revert MaxSupplyTooLow(maxSupply_, initialSupply);
        maxSupply = maxSupply_;
        transferOwnership(minter);
    }

    /// @notice Mint an amount of tokens to an account.
    /// @param account The address of the account receiving the tokens.
    /// @param amount The amount of tokens the account receives.
    function mint(address account, uint256 amount) public onlyOwner {
        uint256 total = totalSupply();
        if (total + amount > maxSupply) revert MaxSupplyExceeded(amount, total, maxSupply);
        _mint(account, amount);
    }
}
