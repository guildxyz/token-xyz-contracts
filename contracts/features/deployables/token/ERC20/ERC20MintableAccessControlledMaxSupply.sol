// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ERC20InitialSupply } from "./ERC20InitialSupply.sol";
import { IERC20MaxSupply } from "../../interfaces/IERC20MaxSupply.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title A mintable ERC20 token with role-based access control and capped supply.
contract ERC20MintableAccessControlledMaxSupply is IERC20MaxSupply, ERC20InitialSupply, AccessControl {
    /// @notice The id of the role that has access to the {mint} function.
    bytes32 public immutable MINTER_ROLE = 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6;

    /// @inheritdoc IERC20MaxSupply
    uint256 public immutable maxSupply;

    /// @notice Sets metadata, mints an initial supply and grants minter role to `minter`.
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
        _setRoleAdmin(MINTER_ROLE, MINTER_ROLE);
        _grantRole(MINTER_ROLE, minter);
    }

    /// @notice Mint an amount of tokens to an account.
    /// @param account The address of the account receiving the tokens.
    /// @param amount The amount of tokens the account receives.
    function mint(address account, uint256 amount) public onlyRole(MINTER_ROLE) {
        uint256 total = totalSupply();
        if (total + amount > maxSupply) revert MaxSupplyExceeded(amount, total, maxSupply);
        _mint(account, amount);
    }
}
