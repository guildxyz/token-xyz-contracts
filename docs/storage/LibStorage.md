


## Functions
### getStorageSlot
```solidity
  function getStorageSlot(
    enum LibStorage.StorageId storageId
  ) internal returns (uint256 slot)
```
See: https://solidity.readthedocs.io/en/v0.8.14/assembly.html#access-to-external-variables-functions-and-libraries


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`storageId` | enum LibStorage.StorageId | An entry in `StorageId`

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`slot`| enum LibStorage.StorageId | The storage slot.
