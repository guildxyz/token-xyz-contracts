# MulticallFeature

Provides a function to batch together multiple calls in a single external call.



## Functions
### migrate
```solidity
  function migrate(
  ) external returns (bytes4 success)
```
Initialize and register this feature. Should be delegatecalled by `Migrate.migrate()`.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`success`|  | `LibMigrate.SUCCESS` on success.





## State variables
```solidity
  string FEATURE_NAME;

  uint96 FEATURE_VERSION;
```
