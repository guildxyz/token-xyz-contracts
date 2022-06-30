# ERC20InitialSupply

A non-mintable, ownerless ERC20 token with initial supply.



## Functions
### constructor
```solidity
  constructor(
    string name,
    string symbol,
    uint8 tokenDecimals,
    address owner,
    uint256 initialSupply
  ) 
``` 
Sets metadata and mints an initial supply to `owner`.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`name` | string | The name of the token.
|`symbol` | string | The symbol of the token.
|`tokenDecimals` | uint8 | The number of decimals of the token.
|`owner` | address | The address receiving the initial token supply.
|`initialSupply` | uint256 | The amount of pre-minted tokens.

### decimals
```solidity
  function decimals(
  ) public returns (uint8)
``` 

Returns the number of decimals used to get its user representation.
For example, if `decimals` equals `2`, a balance of `505` tokens should
be displayed to a user as `5.05` (`505 / 10 ** 2`).
Tokens usually opt for a value of 18, imitating the relationship between
Ether and Wei. This is the value {ERC20} uses, unless this function is
overridden;
NOTE: This information is only used for _display_ purposes: it in
no way affects any of the arithmetic of the contract, including
{IERC20-balanceOf} and {IERC20-transfer}.







