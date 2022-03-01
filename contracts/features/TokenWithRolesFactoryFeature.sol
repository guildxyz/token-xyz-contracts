// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./interfaces/ITokenWithRolesFactoryFeature.sol";
import "./deployables/token/ERC20MintableAccessControlled.sol";
import "./deployables/token/ERC20MintableAccessControlledMaxSupply.sol";
import "../fixins/FixinCommon.sol";
import "../storage/LibTokenFactoryStorage.sol";
import "../migrations/LibMigrate.sol";
import "./interfaces/IFeature.sol";

/// @title A contract that deploys ERC20 token contracts with OpenZeppelin's AccessControl for anyone.
contract TokenWithRolesFactoryFeature is IFeature, ITokenWithRolesFactoryFeature, FixinCommon {
    /// @notice Name of this feature.
    string public constant override FEATURE_NAME = "TokenWithRolesFactory";
    /// @notice Version of this feature.
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);

    /// @notice Initialize and register this feature.
    ///      Should be delegatecalled by `Migrate.migrate()`.
    /// @return success `LibMigrate.SUCCESS` on success.
    function migrate() external returns (bytes4 success) {
        _registerFeatureFunction(this.createTokenWithRoles.selector);
        _registerFeatureFunction(this.getDeployedTokens.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    /// @notice Deploys a new ERC20 token contract.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @param tokenName The token's name.
    /// @param tokenSymbol The token's symbol.
    /// @param tokenDecimals The token's number of decimals.
    /// @param initialSupply The initial amount of tokens to mint.
    /// @param maxSupply The maximum amount of tokens that can ever be minted. Unlimited if set to zero.
    /// @param firstOwner The first address to assign ownership/minting rights to (if mintable). The recipient of the initial supply.
    /// @param mintable Whether to create a mintable token.
    // prettier-ignore
    function createTokenWithRoles(
        string calldata urlName,
        string calldata tokenName,
        string calldata tokenSymbol,
        uint8 tokenDecimals,
        uint256 initialSupply,
        uint256 maxSupply,
        address firstOwner,
        bool mintable
    ) external {
        address token;
        if (mintable)
            if (maxSupply > 0)
                token = address(
                    new ERC20MintableAccessControlledMaxSupply(
                        tokenName,
                        tokenSymbol,
                        tokenDecimals,
                        firstOwner,
                        initialSupply,
                        maxSupply
                    )
                );
            else
                token = address(
                    new ERC20MintableAccessControlled(
                        tokenName,
                        tokenSymbol,
                        tokenDecimals,
                        firstOwner,
                        initialSupply
                    )
                );
        else
            token = address(
                new ERC20InitialSupply(
                    tokenName,
                    tokenSymbol,
                    tokenDecimals,
                    firstOwner,
                    initialSupply
                )
            );
        LibTokenFactoryStorage.getStorage().deploys[urlName].push(token);
        emit TokenDeployed(msg.sender, urlName, token);
    }

    /// @notice Returns all the deployed token addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return tokenAddresses The requested array of tokens addresses.
    function getDeployedTokens(string calldata urlName) external view returns (address[] memory tokenAddresses) {
        return LibTokenFactoryStorage.getStorage().deploys[urlName];
    }
}
