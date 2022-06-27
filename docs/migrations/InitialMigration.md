


## Functions
### constructor
```solidity
  function constructor(
    address initializeCaller_
  ) public
```
Instantiate this contract and set the allowed caller of `initializeTokenXyz()` to `initializeCaller_`.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`initializeCaller_` | address | The allowed caller of `initializeTokenXyz()`.

### getBootstrapper
```solidity
  function getBootstrapper(
  ) external returns (address bootstrapper)
```
Retrieve the bootstrapper address to use when constructing `TokenXyz`.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`bootstrapper`|  | The bootstrapper address.
### initializeTokenXyz
```solidity
  function initializeTokenXyz(
    address payable owner,
    contract TokenXyz tokenXyz,
    struct InitialMigration.BootstrapFeatures features
  ) public returns (contract TokenXyz _tokenXyz)
```
Initialize the `TokenXyz` contract with the minimum feature set,
        transfers ownership to `owner`, then self-destructs.
        Only callable by `initializeCaller` set in the contstructor.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`owner` | address payable | The owner of the contract.
|`tokenXyz` | contract TokenXyz | The instance of the TokenXyz contract, constructed with this contract as the bootstrapper.
|`features` | struct InitialMigration.BootstrapFeatures | Features to bootstrap into the proxy.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`_tokenXyz`| address payable | The configured TokenXyz contract. Same as the `tokenXyz` parameter.
### bootstrap
```solidity
  function bootstrap(
    address owner,
    struct InitialMigration.BootstrapFeatures features
  ) public returns (bytes4 success)
```
Sets up the initial state of the `TokenXyz` contract.
        The `TokenXyz` contract will delegatecall into this function.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`owner` | address | The new owner of the TokenXyz contract.
|`features` | struct InitialMigration.BootstrapFeatures | Features to bootstrap into the proxy.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`success`| address | Magic bytes if successful.
### die
```solidity
  function die(
    address payable ethRecipient
  ) public
```
Self-destructs this contract. Only callable by this contract.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`ethRecipient` | address payable | Who to transfer outstanding ETH to.

