# ERC721Curve

An NFT with an ever increasing price along a curve.



## Functions
### constructor
```solidity
  function constructor(
  ) public
```




### getPriceOf
```solidity
  function getPriceOf(
    uint256 tokenId
  ) public returns (uint256)
```
Gets the price of a specific token.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`tokenId` | uint256 | The ID of the token.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`The`| uint256 | price of the token in wei.
### claim
```solidity
  function claim(
  ) external
```
Claims a token to the given address. Reverts if the price is invalid.



### withdraw
```solidity
  function withdraw(
    address payable recipient
  ) external
```
Allows the owner to withdraw the collected funds.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`recipient` | address payable | The address receiving the tokens.

### tokenURI
```solidity
  function tokenURI(
    uint256 tokenId
  ) public returns (string)
```

Returns the Uniform Resource Identifier (URI) for `tokenId` token.
#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`tokenId` | uint256 | The id of the token.

### totalSupply
```solidity
  function totalSupply(
  ) public returns (uint256)
```
The total amount of tokens stored by the contract.



