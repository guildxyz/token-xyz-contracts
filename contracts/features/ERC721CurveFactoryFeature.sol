// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import { IERC721FactoryCommon } from "./interfaces/IERC721FactoryCommon.sol";
import { IERC721CurveFactoryFeature } from "./interfaces/IERC721CurveFactoryFeature.sol";
import { ERC721Curve } from "./deployables/token/ERC721/ERC721Curve.sol";
import { FixinCommon } from "../fixins/FixinCommon.sol";
import { LibERC721CurveFactoryStorage } from "../storage/LibERC721CurveFactoryStorage.sol";
import { LibMigrate } from "../migrations/LibMigrate.sol";
import { IFeature } from "./interfaces/IFeature.sol";

/// @title A contract that deploys special ERC721 contracts for anyone.
contract ERC721CurveFactoryFeature is IFeature, IERC721CurveFactoryFeature, FixinCommon {
    /// @notice Name of this feature.
    string public constant FEATURE_NAME = "ERC721CurveFactory";
    /// @notice Version of this feature.
    uint96 public immutable FEATURE_VERSION = _encodeVersion(1, 0, 0);

    /// @notice Initialize and register this feature. Should be delegatecalled by `Migrate.migrate()`.
    /// @return success `LibMigrate.SUCCESS` on success.
    function migrate() external returns (bytes4 success) {
        _registerFeatureFunction(this.createNFTWithCurve.selector);
        _registerFeatureFunction(this.getDeployedNFTsWithCurve.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    /// @notice Deploys a new ERC721Curve contract.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @param nftMetadata The basic metadata of the NFT that will be created (name, symbol, ipfsHash, maxSupply).
    /// @param startingPrice The price of the first token that will be minted.
    /// @param owner The owner address of the contract to be deployed. Will have special access to some functions.
    function createNFTWithCurve(
        string calldata urlName,
        IERC721FactoryCommon.NftMetadata calldata nftMetadata,
        uint256 startingPrice,
        address owner
    ) external {
        address instance = address(
            new ERC721Curve(
                nftMetadata.name,
                nftMetadata.symbol,
                nftMetadata.ipfsHash,
                nftMetadata.maxSupply,
                startingPrice,
                owner
            )
        );
        LibERC721CurveFactoryStorage.getStorage().deploys[urlName].push(
            DeployData({ factoryVersion: FEATURE_VERSION, contractAddress: instance })
        );
        emit ERC721CurveDeployed(msg.sender, urlName, instance, FEATURE_VERSION);
    }

    /// @notice Returns all the deployed ERC721Curve contract addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return nftAddresses The requested array of contract addresses.
    function getDeployedNFTsWithCurve(string calldata urlName)
        external
        view
        returns (DeployData[] memory nftAddresses)
    {
        return LibERC721CurveFactoryStorage.getStorage().deploys[urlName];
    }
}
