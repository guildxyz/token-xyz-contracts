# ITokenFactoryFeature

A contract that deploys ERC20 token contracts for anyone.



## Functions
### createToken
```solidity
  function createToken(
    string urlName,
    string tokenName,
    string tokenSymbol,
    uint8 tokenDecimals,
    uint256 initialSupply,
    uint256 maxSupply,
    address firstOwner
  ) external
```
Deploys a new ERC20 token contract.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`urlName` | string | The url name used by the frontend, kind of an id of the creator.
|`tokenName` | string | The token's name.
|`tokenSymbol` | string | The token's symbol.
|`tokenDecimals` | uint8 | The token's number of decimals.
|`initialSupply` | uint256 | The initial amount of tokens to mint.
|`maxSupply` | uint256 | The maximum amount of tokens that can ever be minted. Unlimited if set to zero.
|`firstOwner` | address | The address to assign ownership/minter role to (if mintable). Recipient of the initial supply.

### addToken
```solidity
  function addToken(
    string urlName,
    address tokenAddress
  ) external
```
Adds a token to the contract's storage.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`urlName` | string | The url name used by the frontend, kind of an id of the creator.
|`tokenAddress` | address | The address of the token to add.






