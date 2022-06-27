# MerkleVesting

Allows anyone to claim a token if they exist in a Merkle root, but only over time.



## Functions
### constructor
```solidity
  function constructor(
  ) public
```




### getCohort
```solidity
  function getCohort(
  ) external returns (struct IMerkleVesting.CohortData)
```




### getCohortsLength
```solidity
  function getCohortsLength(
  ) external returns (uint256)
```




### getClaimableAmount
```solidity
  function getClaimableAmount(
  ) public returns (uint256)
```




### getClaimed
```solidity
  function getClaimed(
  ) public returns (uint256)
```




### isDisabled
```solidity
  function isDisabled(
  ) public returns (bool)
```




### setDisabled
```solidity
  function setDisabled(
  ) external
```




### addCohort
```solidity
  function addCohort(
  ) external
```




### claim
```solidity
  function claim(
  ) external
```




### prolongDistributionPeriod
```solidity
  function prolongDistributionPeriod(
  ) external
```




### withdraw
```solidity
  function withdraw(
  ) external
```




### updateAllCohortsEnd
```solidity
  function updateAllCohortsEnd(
  ) internal
```




