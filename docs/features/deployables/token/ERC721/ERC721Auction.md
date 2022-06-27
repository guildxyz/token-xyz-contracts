


## Functions
### constructor
```solidity
  function constructor(
  ) public
```

If startTime is 0, block.timestamp will be used.


### bid
```solidity
  function bid(
  ) external
```




### settleAuction
```solidity
  function settleAuction(
  ) external
```




### setStartingPrice
```solidity
  function setStartingPrice(
  ) external
```




### setAuctionDuration
```solidity
  function setAuctionDuration(
  ) external
```




### setTimeBuffer
```solidity
  function setTimeBuffer(
  ) external
```




### setMinimumPercentageIncreasex100
```solidity
  function setMinimumPercentageIncreasex100(
  ) external
```




### _createAuction
```solidity
  function _createAuction(
  ) internal
```




### _safeMint
```solidity
  function _safeMint(
  ) internal
```




### getAuctionConfig
```solidity
  function getAuctionConfig(
  ) external returns (uint128 startingPrice, uint128 auctionDuration, uint128 timeBuffer, uint128 minimumPercentageIncreasex100)
```




### getAuctionState
```solidity
  function getAuctionState(
  ) external returns (uint256 tokenId, address bidder, uint256 bidAmount, uint128 startTime, uint128 endTime)
```




### tokenURI
```solidity
  function tokenURI(
  ) public returns (string)
```




