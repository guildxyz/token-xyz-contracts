// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title A non-mintable, ownerless ERC20 token with initial supply.
contract ERC20InitialSupply is ERC20 {
    uint8 private _tokenDecimals;

    /// @notice Sets metadata and mints an initial supply to `owner`.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @param tokenDecimals The number of decimals of the token.
    /// @param owner The address receiving the initial token supply.
    /// @param initialSupply The amount of pre-minted tokens.
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

    /// @inheritdoc ERC20
    function decimals() public view override returns (uint8) {
        return _tokenDecimals;
    }
}
