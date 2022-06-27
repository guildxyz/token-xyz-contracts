# WETHMock

A minimal implementation of WETH for testing purposes.


It has many flaws and doesn't work correctly. Don't even think of using it in production!

## Functions
### constructor
```solidity
  function constructor(
  ) public
```




### deposit
```solidity
  function deposit(
  ) external
```
Deposit ether to get wrapped ether.



### withdraw
```solidity
  function withdraw(
    uint256 wad
  ) external
```
Withdraw wrapped ether to get ether.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`wad` | uint256 | The amount of ether to withdraw.

### balanceOf2
```solidity
  function balanceOf2(
  ) public returns (uint256)
```

This should be used instead of the original.


### _transfer
```solidity
  function _transfer(
  ) internal
```




