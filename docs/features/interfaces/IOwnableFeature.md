# IOwnableFeature

Owner management and migration features.



## Functions
### migrate
```solidity
  function migrate(
    address target,
    bytes newOwner,
    address data
  ) external
```
Execute a migration function in the context of the TokenXyz contract.
        The result of the function being called should be the magic bytes
        0x2c64c5ef (`keccak('MIGRATE_SUCCESS')`). Only callable by the owner.
        The owner will be temporarily set to `address(this)` inside the call.
        Before returning, the owner will be set to `newOwner`.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`target` | address | The migrator contract address.
|`newOwner` | bytes | The address of the new owner.
|`data` | address | The call data.

## Events
### Migrated
```solidity
  event Migrated(
    address caller,
    address migrator,
    address newOwner
  )
```
Emitted when `migrate()` is called.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`caller`| address | The caller of `migrate()`.
|`migrator`| address | The migration contract.
|`newOwner`| address | The address of the new owner.
