# IMulticallFeature

Provides a function to batch together multiple calls in a single external call.

## Functions

### multicall

```solidity
  function multicall(
    bytes[] data
  ) external returns (bytes[] results)
```

Receives and executes a batch of function calls on this contract.

#### Parameters:

| Name   | Type    | Description                                 |
| :----- | :------ | :------------------------------------------ |
| `data` | bytes[] | An array of the encoded function call data. |

#### Return Values:

| Name      | Type    | Description                                               |
| :-------- | :------ | :-------------------------------------------------------- |
| `results` | bytes[] | An array of the results of the individual function calls. |
