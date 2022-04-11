// SPDX-License-Identifier: GPL-3.0-or-later

/*

    The file was modified by Agora.
    2022 agora.xyz

*/

pragma solidity 0.8.13;

import "./interfaces/IMerkleNFTMinter.sol";
import "./token/ERC721/ERC721Mintable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleNFTMinter is IMerkleNFTMinter, Ownable {
    address public immutable token;
    bytes32 public immutable merkleRoot;
    uint256 public immutable distributionEnd;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(
        bytes32 merkleRoot_,
        uint256 distributionDuration,
        NftMetadata memory nftMetadata,
        address owner
    ) {
        merkleRoot = merkleRoot_;
        distributionEnd = block.timestamp + distributionDuration;

        token = address(
            new ERC721Mintable(nftMetadata.name, nftMetadata.symbol, nftMetadata.ipfsHash, nftMetadata.maxSupply)
        );

        transferOwnership(owner);
    }

    function isClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(
        uint256 index,
        address account,
        uint256 tokenId,
        bytes32[] calldata merkleProof
    ) external {
        if (block.timestamp > distributionEnd) revert DistributionEnded(block.timestamp, distributionEnd);
        if (isClaimed(index)) revert DropClaimed();

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, tokenId));
        if (!MerkleProof.verify(merkleProof, merkleRoot, node)) revert InvalidProof();

        // Mark it claimed and mint the token.
        _setClaimed(index);
        ERC721Mintable(token).safeMint(account, tokenId);

        emit Claimed(index, account);
    }

    function withdraw(address newOwner) external onlyOwner {
        ERC721Mintable nft = ERC721Mintable(token);
        uint256 remainingNfts = nft.maxSupply() - nft.totalSupply();
        if (block.timestamp <= distributionEnd && remainingNfts > 0)
            revert DistributionOngoing(block.timestamp, distributionEnd, remainingNfts);
        nft.transferOwnership(newOwner);
        emit Withdrawn(token, newOwner);
    }
}