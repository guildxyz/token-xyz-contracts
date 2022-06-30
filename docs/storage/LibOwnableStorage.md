# LibOwnableStorage

Storage helpers for the `Ownable` feature.

## Functions

### getStorage

```solidity
  function getStorage(
  ) internal returns (struct LibOwnableStorage.Storage stor)
```

Get the storage bucket for this contract.

#### Return Values:

| Name   | Type | Description                                                |
| :----- | :--- | :--------------------------------------------------------- |
| `stor` |      | The struct containing the state variables of the contract. |

## Structs

### Storage

```solidity
struct Storage {
  address owner;
}

```
