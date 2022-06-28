# OwnableFeature

Owner management features.



## Functions
### bootstrap
```solidity
  function bootstrap(
  ) external returns (bytes4 success)
```
Initializes this feature. The intial owner will be set to this (TokenXyz)
        to allow the bootstrappers to call `extend()`. Ownership should be
        transferred to the real owner by the bootstrapper after
        bootstrapping is complete.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`success`|  | Magic bytes if successful.
### transferOwnership
```solidity
  function transferOwnership(
    address newOwner
  ) external
```
Change the owner of this contract. Only directly callable by the owner.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`newOwner` | address | New owner address.

### migrate
```solidity
  function migrate(
    address target,
    bytes data,
    address newOwner
  ) external
```
Execute a migration function in the context of the TokenXyz contract.
        The result of the function being called should be the magic bytes
        0x2c64c5ef (`keccack('MIGRATE_SUCCESS')`). Only callable by the owner.
        Temporarily sets the owner to ourselves so we can perform admin functions.
        Before returning, the owner will be set to `newOwner`.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`target` | address | The migrator contract address.
|`data` | bytes | The call data.
|`newOwner` | address | The address of the new owner.

### owner
```solidity
  function owner(
  ) external returns (address owner_)
```
Get the owner of this contract.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`owner_`|  | The owner of this contract.





## State variables
```solidity
  string FEATURE_NAME;

  uint96 FEATURE_VERSION;
```
