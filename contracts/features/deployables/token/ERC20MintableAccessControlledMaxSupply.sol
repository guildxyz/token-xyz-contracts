// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./ERC20InitialSupply.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title A mintable ERC20 token.
contract ERC20MintableAccessControlledMaxSupply is ERC20InitialSupply, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public immutable maxSupply;

    /// @notice Error thrown when the max supply is attempted to be set lower than the initial supply.
    /// @param maxSupply The desired max supply.
    /// @param initialSupply The desired initial supply, that cannot be higher than the max.
    error MaxSupplyTooLow(uint256 maxSupply, uint256 initialSupply);

    /// @notice Error thrown when more tokens are attempted to be minted than the max supply.
    /// @param amount The amount of tokens attempted to be minted.
    /// @param currentSupply The current supply of the token.
    /// @param maxSupply The max supply of the token.
    error MaxSupplyExceeded(uint256 amount, uint256 currentSupply, uint256 maxSupply);

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
