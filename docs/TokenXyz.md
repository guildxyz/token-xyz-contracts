# TokenXyz

An extensible proxy contract that serves as a universal entry point for
interacting with the token.xyz contracts.

## Functions

### constructor

```solidity
  constructor(
    address bootstrapper
  )
```

Constructs this contract and registers the `BootstrapFeature` feature.
After constructing this contract, `bootstrap()` should be called
by `bootstrap()` to seed the initial feature set.

#### Parameters:

| Name           | Type    | Description                 |
| :------------- | :------ | :-------------------------- |
| `bootstrapper` | address | Who can call `bootstrap()`. |

### fallback

```solidity
  fallback(
  ) external
```

Forwards calls to the appropriate implementation contract.

### receive

```solidity
  receive(
  ) external
```

Fallback for just receiving ether.

### getFunctionImplementation

```solidity
  function getFunctionImplementation(
    bytes4 selector
  ) public returns (address impl)
```

Get the implementation contract of a registered function.

#### Parameters:

| Name       | Type   | Description            |
| :--------- | :----- | :--------------------- |
| `selector` | bytes4 | The function selector. |

#### Return Values:

| Name   | Type   | Description                          |
| :----- | :----- | :----------------------------------- |
| `impl` | bytes4 | The implementation contract address. |
