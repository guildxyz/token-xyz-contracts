# ISimpleFunctionRegistryFeature

Basic registry management features.

## Functions

### rollback

```solidity
  function rollback(
    bytes4 selector,
    address targetImpl
  ) external
```

Roll back to a prior implementation of a function.

#### Parameters:

| Name         | Type    | Description                                             |
| :----------- | :------ | :------------------------------------------------------ |
| `selector`   | bytes4  | The function selector.                                  |
| `targetImpl` | address | The address of an older implementation of the function. |

### extend

```solidity
  function extend(
    bytes4 selector,
    address impl
  ) external
```

Register or replace a function.

#### Parameters:

| Name       | Type    | Description                                   |
| :--------- | :------ | :-------------------------------------------- |
| `selector` | bytes4  | The function selector.                        |
| `impl`     | address | The implementation contract for the function. |

### getRollbackLength

```solidity
  function getRollbackLength(
    bytes4 selector
  ) external returns (uint256 rollbackLength)
```

Retrieve the length of the rollback history for a function.

#### Parameters:

| Name       | Type   | Description            |
| :--------- | :----- | :--------------------- |
| `selector` | bytes4 | The function selector. |

#### Return Values:

| Name             | Type   | Description                                     |
| :--------------- | :----- | :---------------------------------------------- |
| `rollbackLength` | bytes4 | The number of items in the rollback history for |

        the function.

### getRollbackEntryAtIndex

```solidity
  function getRollbackEntryAtIndex(
    bytes4 selector,
    uint256 idx
  ) external returns (address impl)
```

Retrieve an entry in the rollback history for a function.

#### Parameters:

| Name       | Type    | Description                        |
| :--------- | :------ | :--------------------------------- |
| `selector` | bytes4  | The function selector.             |
| `idx`      | uint256 | The index in the rollback history. |

#### Return Values:

| Name   | Type   | Description                                   |
| :----- | :----- | :-------------------------------------------- |
| `impl` | bytes4 | An implementation address for the function at |

        index `idx`.

## Events

### ProxyFunctionUpdated

```solidity
  event ProxyFunctionUpdated(
    bytes4 selector,
    address oldImpl,
    address newImpl
  )
```

A function implementation was updated via `extend()` or `rollback()`.

#### Parameters:

| Name       | Type    | Description                                         |
| :--------- | :------ | :-------------------------------------------------- |
| `selector` | bytes4  | The function selector.                              |
| `oldImpl`  | address | The implementation contract address being replaced. |
| `newImpl`  | address | The replacement implementation contract address.    |
