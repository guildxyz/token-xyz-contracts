// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IFactoryFeature.sol";
import "./IERC721FactoryCommon.sol";

/// @title A contract that deploys special ERC721 contracts for anyone.
interface IERC721CurveFactoryFeature is IFactoryFeature {
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
    ) external;

    /// @notice Returns all the deployed ERC721Curve contract addresses by a specific creator.
    /// @param urlName The url name used by the frontend, kind of an id of the creator.
    /// @return nftAddresses The requested array of contract addresses.
    function getDeployedNFTsWithCurve(string calldata urlName) external view returns (DeployData[] memory nftAddresses);

    /// @notice Event emitted when creating a new ERC721Curve contract.
    /// @param deployer The address which created the contract.
    /// @param urlName The urlName, where the created contract is sorted in.
    /// @param instance The address of the newly created contract.
    /// @param factoryVersion The version number of the factory that was used to deploy the contract.
    event ERC721CurveDeployed(address indexed deployer, string urlName, address instance, uint96 factoryVersion);
}
