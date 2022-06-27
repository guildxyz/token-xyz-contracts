


## Functions
### token
```solidity
  function token(
  ) external returns (address)
```
Returns the address of the token distributed by this contract.



### merkleRoot
```solidity
  function merkleRoot(
  ) external returns (bytes32)
```
Returns the Merkle root of the Merkle tree containing account balances available to claim.



### distributionEnd
```solidity
  function distributionEnd(
  ) external returns (uint256)
```
Returns the unix timestamp that marks the end of the token distribution.



### isClaimed
```solidity
  function isClaimed(
    uint256 index
  ) external returns (bool)
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

## Events
### Claimed
```solidity
  event Claimed(
    uint256 index,
    address account,
    uint256 amount
  )
```
This event is triggered whenever a call to #claim succeeds.


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
This event is triggered whenever a call to #prolongDistributionPeriod succeeds.


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
This event is triggered whenever a call to #withdraw succeeds.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`account`| address | The address that received the tokens.
|`amount`| uint256 | The amount of tokens the address received.
