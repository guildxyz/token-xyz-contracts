


## Functions
### transferOwnership
```solidity
  function transferOwnership(
    address newOwner
  ) external
```
Transfers ownership of the contract to a new address.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`newOwner` | address | The address that will become the owner.

### owner
```solidity
  function owner(
  ) external returns (address ownerAddress)
```
The owner of this contract.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`ownerAddress`|  | The owner address.
## Events
### OwnershipTransferred
```solidity
  event OwnershipTransferred(
    address previousOwner,
    address newOwner
  )
```
Emitted by Ownable when ownership is transferred.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`previousOwner`| address | The previous owner of the contract.
|`newOwner`| address | The new owner of the contract.
