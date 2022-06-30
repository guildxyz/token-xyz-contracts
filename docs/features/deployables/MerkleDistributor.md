# MerkleDistributor

Provides ERC20 token distribution based on a Merkle tree.



## Functions
### constructor
```solidity
  constructor(
    address token_,
    bytes32 merkleRoot_,
    uint256 distributionDuration,
    address owner
  ) 
``` 
Sets config and transfers ownership to `owner`.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`token_` | address | The address of the ERC20 token to distribute.
|`merkleRoot_` | bytes32 | The root of the Merkle tree generated from the distribution list.
|`distributionDuration` | uint256 | The time interval while the distribution lasts in seconds.
|`owner` | address | The owner address: will be able to prolong the distribution period and withdraw the remaining tokens.

### isClaimed
```solidity
  function isClaimed(
    uint256 index
  ) public returns (bool claimed)
``` 
Returns true if the index has been marked claimed.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`index` | uint256 | A value from the generated input list.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`claimed`| uint256 | Whether the tokens from `index` have been claimed.
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
Prolongs the distribution period of the tokens. Callable only by the owner.


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
Sends the tokens remaining after the distribution has ended to `recipient`. Callable only by the owner.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`recipient` | address | The address receiving the tokens.






## State variables
```solidity
  address token;

  bytes32 merkleRoot;

  uint256 distributionEnd;
```
