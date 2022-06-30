// SPDX-License-Identifier: GPL-3.0-or-later

/*

  The file has been modified.
  2022 token.xyz

*/

pragma solidity 0.8.15;

import { IMerkleDistributor } from "./interfaces/IMerkleDistributor.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Provides ERC20 token distribution based on a Merkle tree.
contract MerkleDistributor is IMerkleDistributor, Ownable {
    /// @inheritdoc IMerkleDistributor
    address public immutable token;
    /// @inheritdoc IMerkleDistributor
    bytes32 public immutable merkleRoot;
    /// @inheritdoc IMerkleDistributor
    uint256 public distributionEnd;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    /// @notice Sets config and transfers ownership to `owner`.
    /// @param token_ The address of the ERC20 token to distribute.
    /// @param merkleRoot_ The root of the Merkle tree generated from the distribution list.
    /// @param distributionDuration The time interval while the distribution lasts in seconds.
    /// @param owner The owner address: will be able to prolong the distribution period and withdraw the remaining tokens.
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

    /// @inheritdoc IMerkleDistributor
    function isClaimed(uint256 index) public view returns (bool claimed) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    /// Sets tokens on `index` as claimed.
    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    /// @inheritdoc IMerkleDistributor
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

    /// @inheritdoc IMerkleDistributor
    function prolongDistributionPeriod(uint256 additionalSeconds) external onlyOwner {
        uint256 newDistributionEnd = distributionEnd + additionalSeconds;
        distributionEnd = newDistributionEnd;
        emit DistributionProlonged(newDistributionEnd);
    }

    /// @inheritdoc IMerkleDistributor
    function withdraw(address recipient) external onlyOwner {
        if (block.timestamp <= distributionEnd) revert DistributionOngoing(block.timestamp, distributionEnd);
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance == 0) revert AlreadyWithdrawn();
        if (!IERC20(token).transfer(recipient, balance)) revert TransferFailed(token, address(this), recipient);
        emit Withdrawn(recipient, balance);
    }
}
