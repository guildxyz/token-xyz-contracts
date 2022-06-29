# ERC20MintableAccessControlledMaxSupply

A mintable ERC20 token.



## Functions
### constructor
```solidity
  constructor(
  ) 
```




### mint
```solidity
  function mint(
    address account,
    uint256 amount
  ) public
```
Mint an amount of tokens to an account.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`account` | address | The address of the account receiving the tokens.
|`amount` | uint256 | The amount of tokens the account receives.






## State variables
```solidity
  bytes32 MINTER_ROLE;

  uint256 maxSupply;
```
