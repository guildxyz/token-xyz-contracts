# ERC721AuctionMaliciousBidder

A bidder for ERC721Auction that cannot be outbid.



## Functions
### constructor
```solidity
  function constructor(
  ) public
```




### bid
```solidity
  function bid(
    uint256 tokenId
  ) external
```
Calls bid on the auction contract.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`tokenId` | uint256 | The tokenId to bid on.

