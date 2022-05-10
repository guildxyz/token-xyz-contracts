// SPDX-License-Identifier: GPL-3.0-or-later

/*

  The file has been modified.
  2022 token.xyz

*/

pragma solidity 0.8.13;

import "./interfaces/IMerkleDistributor.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Allows anyone to claim a token if they exist in a Merkle root.
contract MerkleDistributor is IMerkleDistributor, Ownable {
    address public immutable token;
    bytes32 public immutable merkleRoot;
    uint256 public distributionEnd;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(
        address token_,
        bytes32 merkleRoot_,
        uint256 distributionDuration,
        address owner
    ) {
        if (owner == address(0) || token_ == address(0) || merkleRoot_ == bytes32(0)) revert InvalidParameters();
        token = token_;
        merkleRoot = merkleRoot_;
        distributionEnd = block.timestamp + distributionDuration;
        _transferOwnership(owner);
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
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        if (block.timestamp > distributionEnd) revert DistributionEnded(block.timestamp, distributionEnd);
        if (isClaimed(index)) revert AlreadyClaimed();

        // Verify the Merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        if (!MerkleProof.verify(merkleProof, merkleRoot, node)) revert InvalidProof();

        // Mark it claimed and send the token.
        _setClaimed(index);
        if (!IERC20(token).transfer(account, amount)) revert TransferFailed(token, address(this), account);

        emit Claimed(index, account, amount);
    }

    function prolongDistributionPeriod(uint256 additionalSeconds) external onlyOwner {
        uint256 newDistributionEnd = distributionEnd + additionalSeconds;
        distributionEnd = newDistributionEnd;
        emit DistributionProlonged(newDistributionEnd);
    }

    function withdraw(address recipient) external onlyOwner {
        if (block.timestamp <= distributionEnd) revert DistributionOngoing(block.timestamp, distributionEnd);
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance == 0) revert AlreadyWithdrawn();
        if (!IERC20(token).transfer(recipient, balance)) revert TransferFailed(token, address(this), recipient);
        emit Withdrawn(recipient, balance);
    }
}
