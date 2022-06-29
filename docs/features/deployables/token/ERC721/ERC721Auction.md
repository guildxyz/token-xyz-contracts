# ERC721Auction

An NFT distributed via on-chain bidding.



## Functions
### constructor
```solidity
  constructor(
  ) 
```

If startTime is 0, block.timestamp will be used.


### bid
```solidity
  function bid(
    uint256 tokenId
  ) external
```
Creates a bid for the specified token with the amount of ether sent along.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`tokenId` | uint256 | The id of the token bid on.

### settleAuction
```solidity
  function settleAuction(
  ) external
```
Sends the token to the highest bidder, mints the next one and transfers the fee to the owner.



### setStartingPrice
```solidity
  function setStartingPrice(
    uint128 newValue
  ) external
```
Sets a new startingPrice. Callable only by the owner.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`newValue` | uint128 | The new value for startingPrice.

### setAuctionDuration
```solidity
  function setAuctionDuration(
    uint128 newValue
  ) external
```
Sets a new auctionDuration. Callable only by the owner.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`newValue` | uint128 | The new value for auctionDuration.

### setTimeBuffer
```solidity
  function setTimeBuffer(
    uint128 newValue
  ) external
```
Sets a new timeBuffer. Callable only by the owner.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`newValue` | uint128 | The new value for timeBuffer.

### setMinimumPercentageIncreasex100
```solidity
  function setMinimumPercentageIncreasex100(
    uint128 newValue
  ) external
```
Sets a new minimumPercentageIncreasex100. Callable only by the owner.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`newValue` | uint128 | The new value for minimumPercentageIncreasex100.

### _createAuction
```solidity
  function _createAuction(
  ) internal
```
Create a new auction if possible and emit an event.



### _safeMint
```solidity
  function _safeMint(
  ) internal
```
An optimized version of {_safeMint} using custom errors.



### getAuctionConfig
```solidity
  function getAuctionConfig(
  ) external returns (uint128 startingPrice, uint128 auctionDuration, uint128 timeBuffer, uint128 minimumPercentageIncreasex100)
```
Returns the configuration of an auction. Properties can be changed only by the owner.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`startingPrice`|  | The starting price of the tokens, i.e. the minimum amount of the first bid.
|`auctionDuration`|  | The duration of the auction of a specific token.
|`timeBuffer`|  | The minimum time until an auction's end after a bid.
|`minimumPercentageIncreasex100`|  | The min. % increase between the previous & the current bid multiplied by 100.
### getAuctionState
```solidity
  function getAuctionState(
  ) external returns (uint256 tokenId, address bidder, uint256 bidAmount, uint128 startTime, uint128 endTime)
```
Returns the state of the current auction.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`tokenId`|  | The id of the token being bid on.
|`bidder`|  | The address that made the last bid.
|`bidAmount`|  | The amount the bidder offered.
|`startTime`|  | The unix timestamp at which the current auction started.
|`endTime`|  | The unix timestamp at which the current auction ends.
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






## State variables
```solidity
  struct IERC721Auction.AuctionConfig auctionConfig;

  struct IERC721Auction.AuctionState auctionState;

  uint256 maxSupply;

  uint256 totalSupply;

  string cid;

  struct Counters.Counter tokenIdCounter;

  address WETH;
```
