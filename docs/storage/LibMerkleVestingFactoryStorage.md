# LibMerkleVestingFactoryStorage

Storage helpers for the `MerkleVestingFactory` feature.



## Functions
### getStorage
```solidity
  function getStorage(
  ) internal returns (struct LibMerkleVestingFactoryStorage.Storage stor)
```
Get the storage bucket for this contract.







## Structs
### Storage
```solidity
  struct Storage{
    mapping(string => struct IFactoryFeature.DeployData[]) deploys;
  }
```

