// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ITokenWithRolesFactoryFeature } from "./interfaces/ITokenWithRolesFactoryFeature.sol";
import { ERC20InitialSupply } from "./deployables/token/ERC20/ERC20InitialSupply.sol";
import { ERC20MintableAccessControlled } from "./deployables/token/ERC20/ERC20MintableAccessControlled.sol";
import { ERC20MintableAccessControlledMaxSupply } from "./deployables/token/ERC20/ERC20MintableAccessControlledMaxSupply.sol"; // solhint-disable-line max-line-length
import { FixinCommon } from "../fixins/FixinCommon.sol";
import { LibTokenFactoryStorage } from "../storage/LibTokenFactoryStorage.sol";
import { LibMigrate } from "../migrations/LibMigrate.sol";
import { IFeature } from "./interfaces/IFeature.sol";

/// @title A contract that deploys ERC20 token contracts with OpenZeppelin's AccessControl for anyone.
contract TokenWithRolesFactoryFeature is IFeature, ITokenWithRolesFactoryFeature, FixinCommon {
    /// @notice Name of this feature.
    string public constant FEATURE_NAME = "TokenWithRolesFactory";
    /// @notice Version of this feature.
    uint96 public immutable FEATURE_VERSION = _encodeVersion(1, 0, 0);

    /// @notice Initialize and register this feature. Should be delegatecalled by `Migrate.migrate()`.
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
    /// @param firstOwner The address to assign ownership/minter role to (if mintable). Recipient of the initial supply.
    // prettier-ignore
    function createTokenWithRoles(
        string calldata urlName,
        string calldata tokenName,
        string calldata tokenSymbol,
        uint8 tokenDecimals,
        uint256 initialSupply,
        uint256 maxSupply,
        address firstOwner
    ) external {
        address token;

        /*
            mintable: initialSupply < maxSupply or either of them is 0
            non-mintable: initialSupply = maxSupply (i.e. fixed supply)
            otherwise revert
        */
        if (initialSupply == 0 || maxSupply == 0 || initialSupply < maxSupply)
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
        else if (initialSupply == maxSupply)
            token = address(
                new ERC20InitialSupply(
                    tokenName,
                    tokenSymbol,
                    tokenDecimals,
                    firstOwner,
                    initialSupply
                )
            );
        else revert MaxSupplyTooLow(maxSupply, initialSupply);
        LibTokenFactoryStorage.getStorage().deploys[urlName].push(
            DeployData({factoryVersion: FEATURE_VERSION, contractAddress: token})
        );
        emit TokenAdded(msg.sender, urlName, token, FEATURE_VERSION);
    }

    /// @notice Returns all the deployed token addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return tokenAddresses The requested array of tokens addresses.
    function getDeployedTokens(string calldata urlName) external view returns (DeployData[] memory tokenAddresses) {
        return LibTokenFactoryStorage.getStorage().deploys[urlName];
    }
}
