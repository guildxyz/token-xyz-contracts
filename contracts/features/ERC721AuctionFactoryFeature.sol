// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IERC721FactoryCommon } from "./interfaces/IERC721FactoryCommon.sol";
import { IERC721AuctionFactoryFeature } from "./interfaces/IERC721AuctionFactoryFeature.sol";
import { IERC721Auction } from "./deployables/interfaces/IERC721Auction.sol";
import { ERC721Auction } from "./deployables/token/ERC721/ERC721Auction.sol";
import { FixinCommon } from "../fixins/FixinCommon.sol";
import { LibERC721AuctionFactoryStorage } from "../storage/LibERC721AuctionFactoryStorage.sol";
import { LibMigrate } from "../migrations/LibMigrate.sol";
import { IFeature } from "./interfaces/IFeature.sol";

/// @title A contract that deploys special ERC721 contracts for anyone.
contract ERC721AuctionFactoryFeature is IFeature, IERC721AuctionFactoryFeature, FixinCommon {
    /// @notice Name of this feature.
    string public constant FEATURE_NAME = "ERC721AuctionFactory";
    /// @notice Version of this feature.
    uint96 public immutable FEATURE_VERSION = _encodeVersion(1, 0, 0);

    /// @notice The address of the wrapped ether (or equivalent) contract.
    address public immutable WETH;

    /// @notice Sets WETH address.
    /// @param weth The address of wrapped ether on the chain the contract is deployed to.
    constructor(address weth) {
        WETH = weth;
    }

    /// @notice Initialize and register this feature. Should be delegatecalled by `Migrate.migrate()`.
    /// @return success `LibMigrate.SUCCESS` on success.
    function migrate() external returns (bytes4 success) {
        _registerFeatureFunction(this.createNFTAuction.selector);
        _registerFeatureFunction(this.getDeployedNFTAuctions.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    /// @notice Deploys a new ERC721Auction contract.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @param nftMetadata The basic metadata of the NFT that will be created (name, symbol, ipfsHash, maxSupply).
    /// @param auctionConfig See {IERC721Auction-AuctionConfig}.
    /// @param startTime The unix timestamp at which the first auction starts. Current time if set to 0.
    /// @param owner The owner address of the contract to be deployed. Will have special access to some functions.
    function createNFTAuction(
        string calldata urlName,
        IERC721FactoryCommon.NftMetadata calldata nftMetadata,
        IERC721Auction.AuctionConfig calldata auctionConfig,
        uint128 startTime,
        address owner
    ) external {
        address instance = address(
            new ERC721Auction(
                nftMetadata.name,
                nftMetadata.symbol,
                nftMetadata.ipfsHash,
                nftMetadata.maxSupply,
                auctionConfig,
                startTime,
                WETH,
                owner
            )
        );
        LibERC721AuctionFactoryStorage.getStorage().deploys[urlName].push(
            DeployData({ factoryVersion: FEATURE_VERSION, contractAddress: instance })
        );
        emit ERC721AuctionDeployed(msg.sender, urlName, instance, FEATURE_VERSION);
    }

    /// @notice Returns all the deployed ERC721Auction contract addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return nftAddresses The requested array of contract addresses.
    function getDeployedNFTAuctions(string calldata urlName) external view returns (DeployData[] memory nftAddresses) {
        return LibERC721AuctionFactoryStorage.getStorage().deploys[urlName];
    }
}
