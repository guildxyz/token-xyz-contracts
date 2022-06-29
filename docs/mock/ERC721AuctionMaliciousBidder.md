# ERC721AuctionMaliciousBidder

A bidder for ERC721Auction that cannot be outbid.



## Functions
### constructor
```solidity
  constructor(
  ) 
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






## State variables
```solidity
  contract IERC721Auction auctionContract;
```
