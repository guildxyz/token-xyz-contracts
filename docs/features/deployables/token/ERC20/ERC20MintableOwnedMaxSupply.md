# ERC20MintableOwnedMaxSupply

A mintable ERC20 token with a single owner and capped supply.



## Functions
### constructor
```solidity
  constructor(
    string name,
    string symbol,
    uint8 tokenDecimals,
    address minter,
    uint256 initialSupply,
    uint256 maxSupply_
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
|`maxSupply_` | uint256 | The maximum amount of tokens that can ever exist.

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
  uint256 maxSupply;
```
