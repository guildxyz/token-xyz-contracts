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
  ) external returns (uint256 price)
```
Gets the price of a specific token.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`tokenId` | uint256 | The ID of the token.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`price`| uint256 | The price of the token in wei.
### maxSupply
```solidity
  function maxSupply(
  ) external returns (uint256 count)
```
The maximum number of NFTs that can ever be minted.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`count`|  | The number of NFTs.
### startingPrice
```solidity
  function startingPrice(
  ) external returns (uint256 price)
```
The price of the first token.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`price`|  | The price in wei.
### totalSupply
```solidity
  function totalSupply(
  ) external returns (uint256 count)
```
The total amount of tokens stored by the contract.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`count`|  | The number of NFTs.

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




