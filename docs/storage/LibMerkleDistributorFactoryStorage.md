# LibMerkleDistributorFactoryStorage

Storage helpers for the `MerkleDistributorFactory` feature.



## Functions
### getStorage
```solidity
  function getStorage(
  ) internal returns (struct LibMerkleDistributorFactoryStorage.Storage stor)
```
Get the storage bucket for this contract.







## Structs
### Storage
```solidity
  struct Storage{
    mapping(string => struct IFactoryFeature.DeployData[]) deploys;
  }
```

