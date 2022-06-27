


## Functions
### constructor
```solidity
  function constructor(
  ) public
```




### claim
```solidity
  function claim(
  ) external
```




### safeMint
```solidity
  function safeMint(
    address to
  ) external
```
Mint the next token to the given address.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`to` | address | The address receiving the token.

### safeBatchMint
```solidity
  function safeBatchMint(
    address to,
    uint256 amount
  ) external
```
Mint a certain amount of tokens to the given address.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`to` | address | The address receiving the tokens.
|`amount` | uint256 | The amount of tokens to mint.

### _safeBatchMint
```solidity
  function _safeBatchMint(
  ) internal
```




### _setClaimed
```solidity
  function _setClaimed(
  ) internal
```




### isClaimed
```solidity
  function isClaimed(
  ) public returns (bool)
```




### tokenURI
```solidity
  function tokenURI(
  ) public returns (string)
```




