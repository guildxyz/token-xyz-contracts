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
    /// @dev Name of this feature.
    string public constant override FEATURE_NAME = "TokenFactory";
    /// @dev Version of this feature.
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);

    /// @dev Initialize and register this feature.
    ///      Should be delegatecalled by `Migrate.migrate()`.
    /// @return success `LibMigrate.SUCCESS` on success.
    function migrate() external returns (bytes4 success) {
        _registerFeatureFunction(this.createToken.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    // prettier-ignore
    function createToken(
        string calldata creator,
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
        LibTokenFactoryStorage.getStorage().deploys[creator].push(token);
        emit TokenDeployed(token);
    }
}
