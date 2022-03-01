// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title A contract that deploys ERC20 token contracts for anyone.
interface ITokenFactoryFeature {
    /// @notice Deploys a new ERC20 token contract.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @param tokenName The token's name.
    /// @param tokenSymbol The token's symbol.
    /// @param tokenDecimals The token's number of decimals.
    /// @param initialSupply The initial amount of tokens to mint.
    /// @param maxSupply The maximum amount of tokens that can ever be minted. Unlimited if set to zero.
    /// @param firstOwner The first address to assign ownership/minting rights to (if mintable). The recipient of the initial supply.
    /// @param mintable Whether to create a mintable token.
    /// @param multiOwner If true, use AccessControl, otherwise Ownable (does not apply if the token is not mintable).
    function createToken(
        string calldata urlName,
        string calldata tokenName,
        string calldata tokenSymbol,
        uint8 tokenDecimals,
        uint256 initialSupply,
        uint256 maxSupply,
        address firstOwner,
        bool mintable,
        bool multiOwner
    ) external;

    /// @notice Returns all the deployed token addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return tokenAddresses The requested array of token addresses.
    function getDeployedTokens(string calldata urlName) external view returns (address[] memory tokenAddresses);

    /// @notice Event emitted when creating a token.
    /// @param deployer The address which created the token.
    /// @param urlName The urlName, where the created token is sorted in.
    /// @param token The address of the newly created token.
    event TokenDeployed(address indexed deployer, string urlName, address token);
}
