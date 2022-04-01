// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20/ERC20.sol";

/// @title An ERC20 token with initial supply.
contract ERC20InitialSupply is ERC20 {
    uint8 private _tokenDecimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 tokenDecimals,
        address owner,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _tokenDecimals = tokenDecimals;
        if (initialSupply > 0) _mint(owner, initialSupply);
    }

    /// @dev See {ERC20-decimals}
    function decimals() public view override returns (uint8) {
        return _tokenDecimals;
    }
}
