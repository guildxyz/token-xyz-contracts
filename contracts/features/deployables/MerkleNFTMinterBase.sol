// SPDX-License-Identifier: GPL-3.0-or-later

/*

  The file has been modified.
  2022 token.xyz

*/

pragma solidity 0.8.13;

import "./interfaces/IMerkleNFTMinter.sol";
import "./token/ERC721/IERC721CappedSupply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Base for a contract that allows anyone to mint a non-fungible token if they exist in a Merkle root.
abstract contract MerkleNFTMinterBase is IMerkleNFTMinter, Ownable {
    address public immutable token;
    bytes32 public immutable merkleRoot;
    uint256 public immutable distributionEnd;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(
        bytes32 merkleRoot_,
        uint256 distributionDuration,
        address tokenAddress,
        address owner
    ) {
        if (owner == address(0) || tokenAddress == address(0) || merkleRoot_ == bytes32(0)) revert InvalidParameters();
        merkleRoot = merkleRoot_;
        distributionEnd = block.timestamp + distributionDuration;
        token = tokenAddress;
        _transferOwnership(owner);
    }

    function isClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) internal {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external virtual;

    function withdraw(address newOwner) external onlyOwner {
        IERC721CappedSupply nft = IERC721CappedSupply(token);
        uint256 remainingNfts = nft.maxSupply() - nft.totalSupply();
        if (block.timestamp <= distributionEnd && remainingNfts > 0)
            revert DistributionOngoing(block.timestamp, distributionEnd, remainingNfts);
        Ownable(token).transferOwnership(newOwner);
        emit Withdrawn(token, newOwner);
    }
}
