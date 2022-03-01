// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./ERC20InitialSupply.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title A mintable ERC20 token
contract ERC20MintableAccessControlled is ERC20InitialSupply, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(
        string memory name,
        string memory symbol,
        uint8 tokenDecimals,
        address minter,
        uint256 initialSupply
    ) ERC20InitialSupply(name, symbol, tokenDecimals, minter, initialSupply) {
        _setRoleAdmin(MINTER_ROLE, MINTER_ROLE);
        _setupRole(MINTER_ROLE, minter);
    }

    /// @notice Mint an amount of tokens to an account
    function mint(address account, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(account, amount);
    }
}
