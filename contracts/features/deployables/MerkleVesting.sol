// SPDX-License-Identifier: GPL-3.0-or-later

/*

  The file has been modified.
  2022 token.xyz

*/

pragma solidity 0.8.13;

import "./interfaces/IMerkleVesting.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";

/// @title Allows anyone to claim a token if they exist in a Merkle root, but only over time.
contract MerkleVesting is IMerkleVesting, Multicall, Ownable {
    address public immutable token;
    bytes32 public lastEndingCohort;

    mapping(bytes32 => Cohort) internal cohorts;

    constructor(address token_, address owner) {
        token = token_;
        transferOwnership(owner);
    }

    function getCohort(bytes32 cohortId) external view returns (CohortData memory) {
        return cohorts[cohortId].data;
    }

    function getClaimableAmount(
        bytes32 cohortId,
        uint256 index,
        address account,
        uint256 fullAmount
    ) public view returns (uint256) {
        Cohort storage cohort = cohorts[cohortId];
        uint256 claimedSoFar = cohort.claims[account];
        uint256 vestingEnd = cohort.data.distributionStart + cohort.data.vestingPeriod;
        uint256 vestingStart = cohort.data.distributionStart;
        uint256 cliff = vestingStart + cohort.data.cliffPeriod;
        if (isDisabled(cohortId, index)) revert NotInVesting(cohortId, account);
        if (block.timestamp < cliff) revert CliffNotReached(block.timestamp, cliff);
        else if (block.timestamp < vestingEnd)
            return (fullAmount * (block.timestamp - vestingStart)) / cohort.data.vestingPeriod - claimedSoFar;
        else return fullAmount - claimedSoFar;
    }

    function getClaimed(bytes32 cohortId, address account) public view returns (uint256) {
        return cohorts[cohortId].claims[account];
    }

    function isDisabled(bytes32 cohortId, uint256 index) public view returns (bool) {
        uint256 wordIndex = index / 256;
        uint256 bitIndex = index % 256;
        uint256 word = cohorts[cohortId].disabledState[wordIndex];
        uint256 mask = (1 << bitIndex);
        return word & mask == mask;
    }

    function setDisabled(bytes32 cohortId, uint256 index) external onlyOwner {
        uint256 wordIndex = index / 256;
        uint256 bitIndex = index % 256;
        cohorts[cohortId].disabledState[wordIndex] = cohorts[cohortId].disabledState[wordIndex] | (1 << bitIndex);
    }

    function addCohort(
        bytes32 merkleRoot,
        uint64 distributionStart,
        uint64 distributionDuration,
        uint64 vestingPeriod,
        uint64 cliffPeriod
    ) external onlyOwner {
        if (
            merkleRoot == bytes32(0) ||
            distributionDuration == 0 ||
            vestingPeriod == 0 ||
            distributionDuration < vestingPeriod ||
            distributionDuration < cliffPeriod ||
            vestingPeriod < cliffPeriod
        ) revert InvalidParameters();
        if (cohorts[merkleRoot].data.merkleRoot != bytes32(0)) revert MerkleRootCollision();

        uint64 distributionStartActual;
        if (distributionStart == 0) distributionStartActual = uint64(block.timestamp);
        else distributionStartActual = distributionStart;

        uint64 distributionEnd = distributionStartActual + distributionDuration;
        if (distributionEnd < block.timestamp) revert DistributionEnded(block.timestamp, distributionEnd);
        updateLastEndingCohort(distributionEnd, merkleRoot);

        cohorts[merkleRoot].data.merkleRoot = merkleRoot;
        cohorts[merkleRoot].data.distributionStart = distributionStartActual;
        cohorts[merkleRoot].data.distributionEnd = distributionEnd;
        cohorts[merkleRoot].data.vestingPeriod = vestingPeriod;
        cohorts[merkleRoot].data.cliffPeriod = cliffPeriod;

        emit CohortAdded(merkleRoot);
    }

    function claim(
        bytes32 cohortId,
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        if (cohorts[cohortId].data.merkleRoot == bytes32(0)) revert CohortDoesNotExist();
        Cohort storage cohort = cohorts[cohortId];
        uint256 distributionEndLocal = cohort.data.distributionEnd;

        if (block.timestamp > distributionEndLocal) revert DistributionEnded(block.timestamp, distributionEndLocal);
        if (block.timestamp < cohort.data.distributionStart)
            revert DistributionNotStarted(block.timestamp, cohort.data.distributionStart);

        // Verify the Merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        if (!MerkleProof.verify(merkleProof, cohort.data.merkleRoot, node)) revert InvalidProof();

        // Calculate the claimable amount and update the claimed amount on storage.
        uint256 claimableAmount = getClaimableAmount(cohortId, index, account, amount);
        cohort.claims[account] += claimableAmount;

        // Send the token.
        if (!IERC20(token).transfer(account, claimableAmount)) revert TransferFailed(token, address(this), account);

        emit Claimed(cohortId, account, claimableAmount);
    }

    function prolongDistributionPeriod(bytes32 cohortId, uint64 additionalSeconds) external onlyOwner {
        CohortData storage cohortData = cohorts[cohortId].data;
        uint64 newDistributionEnd = cohortData.distributionEnd + additionalSeconds;
        cohortData.distributionEnd = newDistributionEnd;
        updateLastEndingCohort(newDistributionEnd, cohortId);
        emit DistributionProlonged(cohortId, newDistributionEnd);
    }

    function withdraw(address recipient) external onlyOwner {
        uint256 distributionEndLocal = cohorts[lastEndingCohort].data.distributionEnd;
        if (block.timestamp <= distributionEndLocal) revert DistributionOngoing(block.timestamp, distributionEndLocal);
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance == 0) revert AlreadyWithdrawn();
        if (!IERC20(token).transfer(recipient, balance)) revert TransferFailed(token, address(this), recipient);
        emit Withdrawn(recipient, balance);
    }

    // Checks if lastEndingCohort should be updated and updates it with the new Merkle root if needed.
    function updateLastEndingCohort(uint256 distributionEnd, bytes32 merkleRoot) internal {
        if (distributionEnd > cohorts[lastEndingCohort].data.distributionEnd) lastEndingCohort = merkleRoot;
    }
}
