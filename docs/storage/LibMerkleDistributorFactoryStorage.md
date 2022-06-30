# LibMerkleDistributorFactoryStorage

Storage helpers for the `MerkleDistributorFactory` feature.



## Functions
### getStorage
```solidity
  function getStorage(
  ) internal returns (struct LibMerkleDistributorFactoryStorage.Storage stor)
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
    mapping(string => struct IFactoryFeature.DeployData[]) deploys;
  }
```

