# LibBytesV06

## Functions

### readBytes4

```solidity
  function readBytes4(
    bytes b,
    uint256 index
  ) internal returns (bytes4 result)
```

Reads an unpadded bytes4 value from a position in a byte array.

#### Parameters:

| Name    | Type    | Description                           |
| :------ | :------ | :------------------------------------ |
| `b`     | bytes   | Byte array containing a bytes4 value. |
| `index` | uint256 | Index in byte array of bytes4 value.  |

#### Return Values:

| Name     | Type  | Description                   |
| :------- | :---- | :---------------------------- |
| `result` | bytes | bytes4 value from byte array. |
