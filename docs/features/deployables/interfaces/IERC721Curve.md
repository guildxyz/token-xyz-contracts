# IERC721Curve

An NFT with an ever increasing price along a curve.



## Functions
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

### getPriceOf
```solidity
  function getPriceOf(
    uint256 tokenId
  ) external returns (uint256)
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
### maxSupply
```solidity
  function maxSupply(
  ) external returns (uint256)
```
The maximum number of NFTs that can ever be minted.



### startingPrice
```solidity
  function startingPrice(
  ) external returns (uint256)
```
The price of the first token.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`The`|  | price in wei.
### totalSupply
```solidity
  function totalSupply(
  ) external returns (uint256)
```
The total amount of tokens stored by the contract.



## Events
### Withdrawn
```solidity
  event Withdrawn(
    address account,
    uint256 amount
  )
```
This event is triggered whenever a call to {withdraw} succeeds.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`account`| address | The address that received the tokens.
|`amount`| uint256 | The amount of tokens the address received.
