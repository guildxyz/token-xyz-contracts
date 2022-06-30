# MerkleVesting

Provides ERC20 token distribution over time, based on a Merkle tree.



## Functions
### constructor
```solidity
  constructor(
    address token_,
    address owner
  ) 
``` 
Sets the token address and transfers ownership to `owner`.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`token_` | address | The address of the ERC20 token to distribute.
|`owner` | address | The owner address: will be able to manage cohorts and withdraw the remaining tokens.

### getCohort
```solidity
  function getCohort(
    uint256 cohortId
  ) external returns (struct IMerkleVesting.CohortData cohort)
``` 
Returns the parameters of a specific cohort.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`cohortId` | uint256 | The id of the cohort.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`cohort`| uint256 | The merkleRoot, distributionStart, distributionEnd, vestingPeriod and cliffPeriod of the cohort.
### getCohortsLength
```solidity
  function getCohortsLength(
  ) external returns (uint256 count)
``` 
Returns the number of created cohorts.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`count`|  | The number of created cohorts.
### getClaimableAmount
```solidity
  function getClaimableAmount(
    uint256 cohortId,
    uint256 index,
    address account,
    uint256 fullAmount
  ) public returns (uint256 amount)
``` 
Returns the amount of funds an account can claim at the moment.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`cohortId` | uint256 | The id of the cohort.
|`index` | uint256 | A value from the generated input list.
|`account` | address | The address of the account to query.
|`fullAmount` | uint256 | The full amount of funds the account can claim.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`amount`| uint256 | The amount of tokens in wei.
### getClaimed
```solidity
  function getClaimed(
    uint256 cohortId,
    address account
  ) public returns (uint256 amount)
``` 
Returns the amount of funds an account has claimed.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`cohortId` | uint256 | The id of the cohort.
|`account` | address | The address of the account to query.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`amount`| uint256 | The amount of tokens in wei.
### isDisabled
```solidity
  function isDisabled(
    uint256 cohortId,
    uint256 index
  ) public returns (bool)
``` 
Check if the address in a cohort at the index is excluded from the vesting.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`cohortId` | uint256 | The id of the cohort.
|`index` | uint256 | A value from the generated input list.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`disabled`| uint256 | Whether the address at `index` has been excluded from the vesting.
### setDisabled
```solidity
  function setDisabled(
    uint256 cohortId,
    uint256 index
  ) external
``` 
Exclude the address in a cohort at the index from the vesting.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`cohortId` | uint256 | The id of the cohort.
|`index` | uint256 | A value from the generated input list.

### addCohort
```solidity
  function addCohort(
    bytes32 merkleRoot,
    uint64 distributionStart,
    uint64 distributionDuration,
    uint64 vestingPeriod,
    uint64 cliffPeriod
  ) external
``` 
Adds a new cohort. Callable only by the owner.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`merkleRoot` | bytes32 | The Merkle root of the cohort. It will also serve as the cohort's ID.
|`distributionStart` | uint64 | The unix timestamp that marks the start of the token distribution. Current time if 0.
|`distributionDuration` | uint64 | The length of the token distribtion period in seconds.
|`vestingPeriod` | uint64 | The length of the vesting period of the tokens in seconds.
|`cliffPeriod` | uint64 | The length of the cliff period in seconds.

### claim
```solidity
  function claim(
    uint256 cohortId,
    uint256 index,
    address account,
    uint256 amount,
    bytes32[] merkleProof
  ) external
``` 
Claim the given amount of the token to the given address. Reverts if the inputs are invalid.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`cohortId` | uint256 | The id of the cohort.
|`index` | uint256 | A value from the generated input list.
|`account` | address | A value from the generated input list.
|`amount` | uint256 | A value from the generated input list (so the full amount).
|`merkleProof` | bytes32[] | An array of values from the generated input list.

### prolongDistributionPeriod
```solidity
  function prolongDistributionPeriod(
    uint256 cohortId,
    uint64 additionalSeconds
  ) external
``` 
Prolongs the distribution period of the tokens. Callable only by the owner.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`cohortId` | uint256 | The id of the cohort.
|`additionalSeconds` | uint64 | The seconds to add to the current distributionEnd.

### withdraw
```solidity
  function withdraw(
    address recipient
  ) external
``` 
Sends the tokens remaining after the distribution has ended to `recipient`. Callable only by the owner.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`recipient` | address | The address receiving the tokens.

### updateAllCohortsEnd
```solidity
  function updateAllCohortsEnd(
  ) internal
``` 
Checks if allCohortsEnd should be updated and updates it with the new timestamp.








## State variables
```solidity
  address token;

  uint256 allCohortsEnd;

  struct IMerkleVesting.Cohort[] cohorts;
```
