# BootstrapFeature

Detachable `bootstrap()` feature.



## Functions
### constructor
```solidity
  function constructor(
    address bootstrapCaller
  ) public
```
Construct this contract and set the bootstrap migration contract.
        After constructing this contract, `bootstrap()` should be called
        to seed the initial feature set.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`bootstrapCaller` | address | The allowed caller of `bootstrap()`.

### bootstrap
```solidity
  function bootstrap(
    address target,
    bytes callData
  ) external
```
Bootstrap the initial feature set of this contract by delegatecalling
        into `target`. Before exiting the `bootstrap()` function will
        deregister itself from the proxy to prevent being called again.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`target` | address | The bootstrapper contract address.
|`callData` | bytes | The call data to execute on `target`.

### die
```solidity
  function die(
  ) external
```
Self-destructs this contract. Can only be called by the deployer.



