// SPDX-License-Identifier: GPL-3.0-or-later

/*

    The file was modified by Agora.
    2022 agora.xyz

*/

pragma solidity 0.8.13;

import "./MerkleNFTMinterBase.sol";
import "./token/ERC721/ERC721MintableAutoId.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

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
                new ERC721MintableAutoId(
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

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        if (!MerkleProof.verify(merkleProof, merkleRoot, node)) revert InvalidProof();

        // Mark it claimed and mint the token(s).
        _setClaimed(index);
        ERC721MintableAutoId(token).safeBatchMint(account, amount);

        emit Claimed(index, account);
    }
}
