# LibTokenFactoryStorage

Storage helpers for the `TokenFactory` feature.



## Functions
### getStorage
```solidity
  function getStorage(
  ) internal returns (struct LibTokenFactoryStorage.Storage stor)
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

