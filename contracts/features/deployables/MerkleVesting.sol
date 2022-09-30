// SPDX-License-Identifier: GPL-3.0-or-later

/*

  The file has been modified.
  2022 token.xyz

*/

pragma solidity 0.8.15;

import { IMerkleVesting } from "./interfaces/IMerkleVesting.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { Multicall } from "@openzeppelin/contracts/utils/Multicall.sol";

/// @title Provides ERC20 token distribution over time, based on a Merkle tree.
contract MerkleVesting is IMerkleVesting, Multicall, Ownable {
    /// @inheritdoc IMerkleVesting
    address public immutable token;
    /// @inheritdoc IMerkleVesting
    uint256 public allCohortsEnd;

    Cohort[] internal cohorts;

    /// @notice Sets the token address and transfers ownership to `owner`.
    /// @param token_ The address of the ERC20 token to distribute.
    /// @param owner The owner address: will be able to manage cohorts and withdraw the remaining tokens.
    constructor(address token_, address owner) {
        if (owner == address(0) || token_ == address(0)) revert InvalidParameters();
        token = token_;
        _transferOwnership(owner);
    }

    /// @inheritdoc IMerkleVesting
    function getCohort(uint256 cohortId)
        external
        view
        returns (
            bytes32 merkleRoot,
            uint64 distributionStart,
            uint64 distributionEnd,
            uint64 vestingPeriod,
            uint64 cliffPeriod
        )
    {
        CohortData memory cohort = cohorts[cohortId].data;
        return (
            cohort.merkleRoot,
            cohort.distributionStart,
            cohort.distributionEnd,
            cohort.vestingPeriod,
            cohort.cliffPeriod
        );
    }

    /// @inheritdoc IMerkleVesting
    function getCohortsLength() external view returns (uint256 count) {
        return cohorts.length;
    }

    /// @inheritdoc IMerkleVesting
    function getClaimableAmount(
        uint256 cohortId,
        uint256 index,
        address account,
        uint256 fullAmount
    ) public view returns (uint256 amount) {
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

    /// @inheritdoc IMerkleVesting
    function getClaimed(uint256 cohortId, address account) public view returns (uint256 amount) {
        return cohorts[cohortId].claims[account];
    }

    /// @inheritdoc IMerkleVesting
    function isDisabled(uint256 cohortId, uint256 index) public view returns (bool) {
        uint256 wordIndex = index / 256;
        uint256 bitIndex = index % 256;
        uint256 word = cohorts[cohortId].disabledState[wordIndex];
        uint256 mask = (1 << bitIndex);
        return word & mask == mask;
    }

    /// @inheritdoc IMerkleVesting
    function setDisabled(uint256 cohortId, uint256 index) external onlyOwner {
        uint256 wordIndex = index / 256;
        uint256 bitIndex = index % 256;
        cohorts[cohortId].disabledState[wordIndex] = cohorts[cohortId].disabledState[wordIndex] | (1 << bitIndex);
    }

    /// @inheritdoc IMerkleVesting
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

        uint256 cohortId = cohorts.length;
        Cohort storage newCohort = cohorts.push();

        uint64 distributionStartActual;
        if (distributionStart == 0) distributionStartActual = uint64(block.timestamp);
        else distributionStartActual = distributionStart;

        uint64 distributionEnd = distributionStartActual + distributionDuration;
        if (distributionEnd < block.timestamp) revert DistributionEnded(block.timestamp, distributionEnd);
        updateAllCohortsEnd(distributionEnd);

        newCohort.data.merkleRoot = merkleRoot;
        newCohort.data.distributionStart = distributionStartActual;
        newCohort.data.distributionEnd = distributionEnd;
        newCohort.data.vestingPeriod = vestingPeriod;
        newCohort.data.cliffPeriod = cliffPeriod;

        emit CohortAdded(cohortId);
    }

    /// @inheritdoc IMerkleVesting
    function claim(
        uint256 cohortId,
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        if (cohortId >= cohorts.length) revert CohortDoesNotExist(cohortId);
        Cohort storage cohort = cohorts[cohortId];
        uint256 distributionEndLocal = cohort.data.distributionEnd;

        if (block.timestamp > distributionEndLocal) revert DistributionEnded(block.timestamp, distributionEndLocal);
        if (block.timestamp < cohort.data.distributionStart)
            revert DistributionNotStarted(block.timestamp, cohort.data.distributionStart);

        // Verify the Merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        if (!MerkleProof.verifyCalldata(merkleProof, cohort.data.merkleRoot, node)) revert InvalidProof();

        // Calculate the claimable amount and update the claimed amount on storage.
        uint256 claimableAmount = getClaimableAmount(cohortId, index, account, amount);
        cohort.claims[account] += claimableAmount;

        // Send the token.
        if (!IERC20(token).transfer(account, claimableAmount)) revert TransferFailed(token, address(this), account);

        emit Claimed(cohortId, account, claimableAmount);
    }

    /// @inheritdoc IMerkleVesting
    function prolongDistributionPeriod(uint256 cohortId, uint64 additionalSeconds) external onlyOwner {
        CohortData storage cohortData = cohorts[cohortId].data;
        uint64 newDistributionEnd = cohortData.distributionEnd + additionalSeconds;
        cohortData.distributionEnd = newDistributionEnd;
        updateAllCohortsEnd(newDistributionEnd);
        emit DistributionProlonged(cohortId, newDistributionEnd);
    }

    /// @inheritdoc IMerkleVesting
    function withdraw(address recipient) external onlyOwner {
        if (block.timestamp <= allCohortsEnd) revert DistributionOngoing(block.timestamp, allCohortsEnd);
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance == 0) revert AlreadyWithdrawn();
        if (!IERC20(token).transfer(recipient, balance)) revert TransferFailed(token, address(this), recipient);
        emit Withdrawn(recipient, balance);
    }

    /// Checks if allCohortsEnd should be updated and updates it with the new timestamp.
    function updateAllCohortsEnd(uint256 distributionEnd) internal {
        if (distributionEnd > allCohortsEnd) allCohortsEnd = distributionEnd;
    }
}
