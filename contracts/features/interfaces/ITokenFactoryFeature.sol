// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ITokenFactoryBase } from "./ITokenFactoryBase.sol";

/// @title A contract that deploys ERC20 token contracts for anyone.
interface ITokenFactoryFeature is ITokenFactoryBase {
    /// @notice Deploys a new ERC20 token contract.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @param tokenName The token's name.
    /// @param tokenSymbol The token's symbol.
    /// @param tokenDecimals The token's number of decimals.
    /// @param initialSupply The initial amount of tokens to mint.
    /// @param maxSupply The maximum amount of tokens that can ever be minted. Unlimited if set to zero.
    /// @param firstOwner The address to assign ownership/minter role to (if mintable). Recipient of the initial supply.
    function createToken(
        string calldata urlName,
        string calldata tokenName,
        string calldata tokenSymbol,
        uint8 tokenDecimals,
        uint256 initialSupply,
        uint256 maxSupply,
        address firstOwner
    ) external;

    /// @notice Adds a token to the contract's storage.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @param tokenAddress The address of the token to add.
    function addToken(string calldata urlName, address tokenAddress) external;
}
