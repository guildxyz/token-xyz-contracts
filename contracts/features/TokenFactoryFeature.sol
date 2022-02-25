// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./interfaces/ITokenFactoryFeature.sol";
import "./deployables/token/ERC20MintableAccessControlled.sol";
import "./deployables/token/ERC20MintableOwned.sol";
import "../fixins/FixinCommon.sol";
import "../storage/LibTokenFactoryStorage.sol";
import "../migrations/LibMigrate.sol";
import "./interfaces/IFeature.sol";

contract TokenFactoryFeature is IFeature, ITokenFactoryFeature, FixinCommon {
    /// @notice Name of this feature.
    string public constant override FEATURE_NAME = "TokenFactory";
    /// @notice Version of this feature.
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);

    /// @notice Initialize and register this feature.
    ///      Should be delegatecalled by `Migrate.migrate()`.
    /// @return success `LibMigrate.SUCCESS` on success.
    function migrate() external returns (bytes4 success) {
        _registerFeatureFunction(this.createToken.selector);
        _registerFeatureFunction(this.getDeployedTokens.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    /// @notice Deploys a new ERC20 token contract.
    /// @param creatorId The id of the creator.
    /// @param tokenName The token's name.
    /// @param tokenSymbol The token's symbol.
    /// @param tokenDecimals The token's number of decimals.
    /// @param initialSupply The initial amount of tokens to mint.
    /// @param firstOwner The first address to assign ownership/minting rights to (if mintable). The recipient of the initial supply.
    /// @param mintable Whether to create a mintable token.
    /// @param multiOwner If true, use AccessControl, otherwise Ownable (does not apply if the token is not mintable).
    // prettier-ignore
    function createToken(
        string calldata creatorId,
        string calldata tokenName,
        string calldata tokenSymbol,
        uint8 tokenDecimals,
        uint256 initialSupply,
        address firstOwner,
        bool mintable,
        bool multiOwner
    ) external {
        address token;
        if (mintable)
            if (multiOwner)
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
                    new ERC20MintableOwned(
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
        LibTokenFactoryStorage.getStorage().deploys[creatorId].push(token);
        emit TokenDeployed(token);
    }

    /// @notice Returns all the deployed token addresses by a specific creator.
    /// @param creatorId The id of the creator.
    /// @return tokenAddresses The requested array of tokens addresses.
    function getDeployedTokens(string calldata creatorId) external view returns (address[] memory tokenAddresses) {
        return LibTokenFactoryStorage.getStorage().deploys[creatorId];
    }
}
