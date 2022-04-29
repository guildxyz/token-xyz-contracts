// SPDX-License-Identifier: GPL-3.0-or-later

/*

  The file has been modified.
  2022 token.xyz

*/

pragma solidity 0.8.13;

import "./MerkleNFTMinterBase.sol";
import "./token/ERC721/ERC721AutoIdBatchMint.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Allows anyone to mint a certain amount of non-fungible tokens if they exist in a Merkle root.
contract MerkleNFTMinterAutoId is MerkleNFTMinterBase {
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
                new ERC721AutoIdBatchMint(
                    nftMetadata.name,
                    nftMetadata.symbol,
                    nftMetadata.ipfsHash,
                    nftMetadata.maxSupply
                )
            ),
            owner
        )
    {}

    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external override {
        if (block.timestamp > distributionEnd) revert DistributionEnded(block.timestamp, distributionEnd);
        if (isClaimed(index)) revert DropClaimed();

        // Verify the Merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        if (!MerkleProof.verify(merkleProof, merkleRoot, node)) revert InvalidProof();

        // Mark it claimed and mint the token(s).
        _setClaimed(index);
        ERC721AutoIdBatchMint(token).safeBatchMint(account, amount);

        emit Claimed(index, account);
    }
}
