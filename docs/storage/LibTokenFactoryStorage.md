# LibTokenFactoryStorage

Storage helpers for the `TokenFactory` feature.



## Functions
### getStorage
```solidity
  function getStorage(
  ) internal returns (struct LibTokenFactoryStorage.Storage stor)
```
Get the storage bucket for this contract.







## Structs
### Storage
```solidity
  struct Storage{
    mapping(string => struct IFactoryFeature.DeployData[]) deploys;
  }
```

