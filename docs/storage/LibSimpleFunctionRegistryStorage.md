# LibSimpleFunctionRegistryStorage

Storage helpers for the `SimpleFunctionRegistry` feature.



## Functions
### getStorage
```solidity
  function getStorage(
  ) internal returns (struct LibSimpleFunctionRegistryStorage.Storage stor)
```
Get the storage bucket for this contract.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`stor`|  | The struct containing the state variables of the contract.




## Structs
### Storage
```solidity
  struct Storage{
    mapping(bytes4 => address[]) implHistory;
  }
```

