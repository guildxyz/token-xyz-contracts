// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./ERC20InitialSupply.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title A mintable ERC20 token
contract ERC20MintableAccessControlledMaxSupply is ERC20InitialSupply, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public immutable maxSupply;

    error MaxSupplyTooLow(uint256 maxSupply, uint256 initialSupply);
    error MaxSupplyExceeded(uint256 amount, uint256 maxSupply);

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
        _setupRole(MINTER_ROLE, minter);
    }

    /// @notice Mint an amount of tokens to an account
    function mint(address account, uint256 amount) public onlyRole(MINTER_ROLE) {
        uint256 total = totalSupply();
        if (total + amount > maxSupply) revert MaxSupplyExceeded(total + amount, total);
        _mint(account, amount);
    }
}
