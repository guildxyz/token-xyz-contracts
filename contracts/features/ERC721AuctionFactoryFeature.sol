// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./interfaces/IERC721AuctionFactoryFeature.sol";
import "./deployables/token/ERC721/ERC721Auction.sol";
import "../fixins/FixinCommon.sol";
import "../storage/LibERC721AuctionFactoryStorage.sol";
import "../migrations/LibMigrate.sol";
import "./interfaces/IFeature.sol";

/// @title A contract that deploys special ERC721 contracts for anyone.
contract ERC721AuctionFactoryFeature is IFeature, IERC721AuctionFactoryFeature, FixinCommon {
    /// @notice Name of this feature.
    string public constant FEATURE_NAME = "ERC721AuctionFactory";
    /// @notice Version of this feature.
    uint96 public immutable FEATURE_VERSION = _encodeVersion(1, 0, 0);

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
                owner
            )
        );
        LibERC721AuctionFactoryStorage.getStorage().deploys[urlName].push(
            DeployData({factoryVersion: FEATURE_VERSION, contractAddress: instance})
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
