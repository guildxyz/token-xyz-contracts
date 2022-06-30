# ERC721AuctionMaliciousBidder

A bidder for ERC721Auction that cannot be outbid.



## Functions
### constructor
```solidity
  constructor(
    contract IERC721Auction auction
  ) 
``` 
Sets the address of an ERC721 auction contract.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`auction` | contract IERC721Auction | The address of an ERC721 auction contract.

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
