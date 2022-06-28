# LibSimpleFunctionRegistryStorage

Storage helpers for the `SimpleFunctionRegistry` feature.



## Functions
### getStorage
```solidity
  function getStorage(
  ) internal returns (struct LibSimpleFunctionRegistryStorage.Storage stor)
```
Get the storage bucket for this contract.







## Structs
### Storage
```solidity
  struct Storage{
    mapping(bytes4 => address[]) implHistory;
  }
```

