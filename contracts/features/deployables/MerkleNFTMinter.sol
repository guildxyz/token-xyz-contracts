// SPDX-License-Identifier: GPL-3.0-or-later

/*

    The file was modified by Agora.
    2022 agora.xyz

*/

pragma solidity 0.8.13;

import "./MerkleNFTMinterBase.sol";
import "./token/ERC721/ERC721Mintable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Allows anyone to mint a non-fungible token with a specific ID if they exist in a Merkle root.
contract MerkleNFTMinter is MerkleNFTMinterBase {
    constructor(
        bytes32 merkleRoot_,
        uint256 distributionDuration,
        NftMetadata memory nftMetadata,
        address owner
    )
        MerkleNFTMinterBase(
            merkleRoot_,
            distributionDuration,
            address(
                new ERC721Mintable(nftMetadata.name, nftMetadata.symbol, nftMetadata.ipfsHash, nftMetadata.maxSupply)
            ),
            owner
        )
    {}

    function claim(
        uint256 index,
        address account,
        uint256 tokenId,
        bytes32[] calldata merkleProof
    ) external override {
        if (block.timestamp > distributionEnd) revert DistributionEnded(block.timestamp, distributionEnd);
        if (isClaimed(index)) revert DropClaimed();

        // Verify the Merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, tokenId));
        if (!MerkleProof.verify(merkleProof, merkleRoot, node)) revert InvalidProof();

        // Mark it claimed and mint the token.
        _setClaimed(index);
        ERC721Mintable(token).safeMint(account, tokenId);

        emit Claimed(index, account);
    }
}
