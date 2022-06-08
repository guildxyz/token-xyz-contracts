// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IFactoryFeature } from "./IFactoryFeature.sol";
import { IERC721FactoryCommon } from "./IERC721FactoryCommon.sol";
import { IERC721Auction } from "../deployables/interfaces/IERC721Auction.sol";

/// @title A contract that deploys special ERC721 contracts for anyone.
interface IERC721AuctionFactoryFeature is IFactoryFeature {
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
    ) external;

    /// @notice Returns all the deployed ERC721Auction contract addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return nftAddresses The requested array of contract addresses.
    function getDeployedNFTAuctions(string calldata urlName) external view returns (DeployData[] memory nftAddresses);

    /// @notice The address of the wrapped ether (or equivalent) contract.
    function WETH() external returns (address); // solhint-disable-line func-name-mixedcase

    /// @notice Event emitted when creating a new ERC721Auction contract.
    /// @param deployer The address which created the contract.
    /// @param urlName The urlName, where the created contract is sorted in.
    /// @param instance The address of the newly created contract.
    /// @param factoryVersion The version number of the factory that was used to deploy the contract.
    event ERC721AuctionDeployed(address indexed deployer, string urlName, address instance, uint96 factoryVersion);
}
