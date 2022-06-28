# LibAddress

Library for functions related to addresses.



## Functions
### sendEther
```solidity
  function sendEther(
    address payable recipient,
    uint256 amount
  ) internal
```
Send ether to an address, forwarding all available gas and reverting on errors.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`recipient` | address payable | The recipient of the ether.
|`amount` | uint256 | The amount of ether to send in wei.

### sendEtherWithFallback
```solidity
  function sendEtherWithFallback(
    address payable recipient,
    uint256 amount,
    address fallbackToken
  ) internal
```
Similar to {sendEther}, but converts the value to `fallbackToken` and sends it anyways on failure.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`recipient` | address payable | The recipient of the ether.
|`amount` | uint256 | The amount of ether to send in wei.
|`fallbackToken` | address | A token compatible with WETH's interface.






