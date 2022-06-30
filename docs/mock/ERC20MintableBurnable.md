# ERC20MintableBurnable

A mintable and burnable ERC20 token with a single owner.



## Functions
### constructor
```solidity
  constructor(
    string name,
    string symbol,
    uint8 tokenDecimals,
    address minter,
    uint256 initialSupply
  ) 
``` 
Sets metadata, mints an initial supply and transfers ownership to `minter`.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`name` | string | The name of the token.
|`symbol` | string | The symbol of the token.
|`tokenDecimals` | uint8 | The number of decimals of the token.
|`minter` | address | The address receiving the initial token supply that will also have permissions to mint it later.
|`initialSupply` | uint256 | The amount of pre-minted tokens.

### burn
```solidity
  function burn(
    address account,
    uint256 amount
  ) public
``` 
Burn `amount` of tokens from `account`.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`account` | address | The address of the account to burn tokens from.
|`amount` | uint256 | The amount of tokens to burn in wei.






