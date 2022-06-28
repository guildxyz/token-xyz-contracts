# MerkleDistributor

Allows anyone to claim a token if they exist in a Merkle root.



## Functions
### constructor
```solidity
  function constructor(
  ) public
```




### isClaimed
```solidity
  function isClaimed(
    uint256 index
  ) public returns (bool)
```
Returns true if the index has been marked claimed.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`index` | uint256 | A value from the generated input list.

### claim
```solidity
  function claim(
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
|`index` | uint256 | A value from the generated input list.
|`account` | address | A value from the generated input list.
|`amount` | uint256 | A value from the generated input list.
|`merkleProof` | bytes32[] | An array of values from the generated input list.

### prolongDistributionPeriod
```solidity
  function prolongDistributionPeriod(
    uint256 additionalSeconds
  ) external
```
Allows the owner to prolong the distribution period of the tokens.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`additionalSeconds` | uint256 | The seconds to add to the current distributionEnd.

### withdraw
```solidity
  function withdraw(
    address recipient
  ) external
```
Allows the owner to reclaim the tokens after the distribution has ended.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`recipient` | address | The address receiving the tokens.

