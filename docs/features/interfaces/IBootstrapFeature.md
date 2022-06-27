# IBootstrapFeature

Detachable `bootstrap()` feature.



## Functions
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

