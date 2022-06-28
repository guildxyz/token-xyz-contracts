# LibERC721MerkleDropFactoryStorage

Storage helpers for the `ERC721MerkleDropFactory` feature.



## Functions
### getStorage
```solidity
  function getStorage(
  ) internal returns (struct LibERC721MerkleDropFactoryStorage.Storage stor)
```
Get the storage bucket for this contract.







## Structs
### Storage
```solidity
  struct Storage{
    mapping(string => struct IFactoryFeature.DeployData[]) deploys;
  }
```

