# IMerkleDistributor

Provides ERC20 token distribution based on a Merkle tree.



## Functions
### token
```solidity
  function token(
  ) external returns (address tokenAddress)
``` 
Returns the address of the token distributed by this contract.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`tokenAddress`|  | The address of the token.
### merkleRoot
```solidity
  function merkleRoot(
  ) external returns (bytes32 root)
``` 
Returns the Merkle root of the Merkle tree containing account balances available to claim.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`root`|  | The root hash of the Merkle tree.
### distributionEnd
```solidity
  function distributionEnd(
  ) external returns (uint256 unixSeconds)
``` 
Returns the unix timestamp that marks the end of the token distribution.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`unixSeconds`|  | The unix timestamp in seconds.
### isClaimed
```solidity
  function isClaimed(
    uint256 index
  ) external returns (bool claimed)
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


## Events
### Claimed
```solidity
  event Claimed(
    uint256 index,
    address account,
    uint256 amount
  )
```
This event is triggered whenever a call to {claim} succeeds.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`index`| uint256 | A value from the generated input list.
|`account`| address | A value from the generated input list.
|`amount`| uint256 | A value from the generated input list.
### DistributionProlonged
```solidity
  event DistributionProlonged(
    uint256 newDistributionEnd
  )
```
This event is triggered whenever a call to {prolongDistributionPeriod} succeeds.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`newDistributionEnd`| uint256 | The time when the distribution ends.
### Withdrawn
```solidity
  event Withdrawn(
    address account,
    uint256 amount
  )
```
This event is triggered whenever a call to {withdraw} succeeds.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`account`| address | The address that received the tokens.
|`amount`| uint256 | The amount of tokens the address received.




