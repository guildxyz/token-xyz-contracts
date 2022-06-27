


## Functions
### constructor
```solidity
  function constructor(
  ) internal
```




### _registerFeatureFunction
```solidity
  function _registerFeatureFunction(
    bytes4 selector
  ) internal
```
Registers a function implemented by this feature at `_implementation`.
        Can and should only be called within a `migrate()`.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`selector` | bytes4 | The selector of the function whose implementation
       is at `_implementation`.

### _encodeVersion
```solidity
  function _encodeVersion(
    uint32 major,
    uint32 minor,
    uint32 revision
  ) internal returns (uint96 encodedVersion)
```
Encode a feature version as a `uint256`.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`major` | uint32 | The major version number of the feature.
|`minor` | uint32 | The minor version number of the feature.
|`revision` | uint32 | The revision number of the feature.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`encodedVersion`| uint32 | The encoded version number.
