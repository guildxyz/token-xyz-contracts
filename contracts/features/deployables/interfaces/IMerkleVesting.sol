// SPDX-License-Identifier: GPL-3.0-or-later

/*

  The file has been modified.
  2022 token.xyz

*/

pragma solidity ^0.8.0;

/// @title Provides ERC20 token distribution over time, based on a Merkle tree.
interface IMerkleVesting {
    /// @notice The struct holding a specific cohort's data and the individual claim statuses.
    /// @param data The struct holding a specific cohort's data.
    /// @param claims Stores the amount of claimed funds per address.
    /// @param disabledState A packed array of booleans. If true, the individual user cannot claim anymore.
    struct Cohort {
        CohortData data;
        mapping(address => uint256) claims;
        mapping(uint256 => uint256) disabledState;
    }

    /// @notice The struct holding a specific cohort's data.
    /// @param merkleRoot The Merkle root of the Merkle tree containing account balances available to claim.
    /// @param distributionStart The unix timestamp that marks the start of the token distribution.
    /// @param distributionEnd The unix timestamp that marks the end of the token distribution.
    /// @param vestingPeriod The length of the vesting period in seconds.
    /// @param cliffPeriod The length of the cliff period in seconds.
    struct CohortData {
        bytes32 merkleRoot;
        uint64 distributionStart;
        uint64 distributionEnd;
        uint64 vestingPeriod;
        uint64 cliffPeriod;
    }

    /// @notice Returns the address of the token distributed by this contract.
    /// @return tokenAddress The address of the token.
    function token() external view returns (address tokenAddress);

    /// @notice Returns the timestamp when all cohorts' distribution period ends.
    /// @return unixSeconds The unix timestamp in seconds.
    function allCohortsEnd() external view returns (uint256 unixSeconds);

    /// @notice Returns the parameters of a specific cohort.
    /// @param cohortId The id of the cohort.
    /// @return cohort The merkleRoot, distributionStart, distributionEnd, vestingPeriod and cliffPeriod of the cohort.
    function getCohort(uint256 cohortId) external view returns (CohortData memory cohort);

    /// @notice Returns the number of created cohorts.
    /// @return count The number of created cohorts.
    function getCohortsLength() external view returns (uint256 count);

    /// @notice Returns the amount of funds an account can claim at the moment.
    /// @param cohortId The id of the cohort.
    /// @param index A value from the generated input list.
    /// @param account The address of the account to query.
    /// @param fullAmount The full amount of funds the account can claim.
    /// @return amount The amount of tokens in wei.
    function getClaimableAmount(
        uint256 cohortId,
        uint256 index,
        address account,
        uint256 fullAmount
    ) external view returns (uint256 amount);

    /// @notice Returns the amount of funds an account has claimed.
    /// @param cohortId The id of the cohort.
    /// @param account The address of the account to query.
    /// @return amount The amount of tokens in wei.
    function getClaimed(uint256 cohortId, address account) external view returns (uint256 amount);

    /// @notice Check if the address in a cohort at the index is excluded from the vesting.
    /// @param cohortId The id of the cohort.
    /// @param index A value from the generated input list.
    /// @return disabled Whether the address at `index` has been excluded from the vesting.
    function isDisabled(uint256 cohortId, uint256 index) external view returns (bool);

    /// @notice Exclude the address in a cohort at the index from the vesting.
    /// @param cohortId The id of the cohort.
    /// @param index A value from the generated input list.
    function setDisabled(uint256 cohortId, uint256 index) external;

    /// @notice Adds a new cohort. Callable only by the owner.
    /// @param merkleRoot The Merkle root of the cohort. It will also serve as the cohort's ID.
    /// @param distributionStart The unix timestamp that marks the start of the token distribution. Current time if 0.
    /// @param distributionDuration The length of the token distribtion period in seconds.
    /// @param vestingPeriod The length of the vesting period of the tokens in seconds.
    /// @param cliffPeriod The length of the cliff period in seconds.
    function addCohort(
        bytes32 merkleRoot,
        uint64 distributionStart,
        uint64 distributionDuration,
        uint64 vestingPeriod,
        uint64 cliffPeriod
    ) external;

    /// @notice Claim the given amount of the token to the given address. Reverts if the inputs are invalid.
    /// @param cohortId The id of the cohort.
    /// @param index A value from the generated input list.
    /// @param account A value from the generated input list.
    /// @param amount A value from the generated input list (so the full amount).
    /// @param merkleProof An array of values from the generated input list.
    function claim(
        uint256 cohortId,
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external;

    /// @notice Prolongs the distribution period of the tokens. Callable only by the owner.
    /// @param cohortId The id of the cohort.
    /// @param additionalSeconds The seconds to add to the current distributionEnd.
    function prolongDistributionPeriod(uint256 cohortId, uint64 additionalSeconds) external;

    /// @notice Sends the tokens remaining after the distribution has ended to `recipient`. Callable only by the owner.
    /// @param recipient The address receiving the tokens.
    function withdraw(address recipient) external;

    /// @notice This event is triggered whenever a call to {addCohort} succeeds.
    /// @param cohortId Theid of the cohort.
    event CohortAdded(uint256 cohortId);

    /// @notice This event is triggered whenever a call to {claim} succeeds.
    /// @param cohortId The id of the cohort.
    /// @param account The address that claimed the tokens.
    /// @param amount The amount of tokens the address received.
    event Claimed(uint256 cohortId, address account, uint256 amount);

    /// @notice This event is triggered whenever a call to {prolongDistributionPeriod} succeeds.
    /// @param cohortId The id of the cohort.
    /// @param newDistributionEnd The time when the distribution ends.
    event DistributionProlonged(uint256 cohortId, uint256 newDistributionEnd);

    /// @notice This event is triggered whenever a call to {withdraw} succeeds.
    /// @param account The address that received the tokens.
    /// @param amount The amount of tokens the address received.
    event Withdrawn(address account, uint256 amount);

    /// @notice Error thrown when there's nothing to withdraw.
    error AlreadyWithdrawn();

    /// @notice Error thrown when a cohort with the provided id does not exist.
    /// @param cohortId The cohort id that does not exist.
    error CohortDoesNotExist(uint256 cohortId);

    /// @notice Error thrown when the distribution period has not started yet.
    /// @param current The current timestamp.
    /// @param start The time when the distribution is starting.
    error DistributionNotStarted(uint256 current, uint256 start);

    /// @notice Error thrown when the distribution period ended.
    /// @param current The current timestamp.
    /// @param end The time when the distribution ended.
    error DistributionEnded(uint256 current, uint256 end);

    /// @notice Error thrown when the cliff period is not over yet.
    /// @param timestamp The current timestamp.
    /// @param cliff The time when the cliff period ends.
    error CliffNotReached(uint256 timestamp, uint256 cliff);

    /// @notice Error thrown when the distribution period did not end yet.
    /// @param current The current timestamp.
    /// @param end The time when the distribution ends.
    error DistributionOngoing(uint256 current, uint256 end);

    /// @notice Error thrown when the Merkle proof is invalid.
    error InvalidProof();

    /// @notice Error thrown when a transfer failed.
    /// @param token The address of token attempted to be transferred.
    /// @param from The sender of the token.
    /// @param to The recipient of the token.
    error TransferFailed(address token, address from, address to);

    /// @notice Error thrown when a function receives invalid parameters.
    error InvalidParameters();

    /// @notice Error thrown when the input address has been excluded from the vesting.
    /// @param cohortId The id of the cohort.
    /// @param account The address that does not satisfy the requirements.
    error NotInVesting(uint256 cohortId, address account);
}
