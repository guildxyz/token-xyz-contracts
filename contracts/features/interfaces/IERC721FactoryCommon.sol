// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Common stuff for ERC721 factories.
interface IERC721FactoryCommon {
    /// @notice The basic metadata of the NFT to be created.
    struct NftMetadata {
        string name;
        string symbol;
        string ipfsHash;
        uint256 maxSupply;
    }
}
