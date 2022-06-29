# IERC721Auction

An NFT distributed via on-chain bidding.



## Functions
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
### AuctionCreated
```solidity
  event AuctionCreated(
    uint256 tokenId,
    uint256 startTime,
    uint256 endTime
  )
```
This event is triggered whenever a new auction is created.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`tokenId`| uint256 | The id of the token to bid on.
|`startTime`| uint256 | The time that the auction is started.
|`endTime`| uint256 | The time that the auction is scheduled to end.
### AuctionDurationChanged
```solidity
  event AuctionDurationChanged(
    uint128 newValue
  )
```
This event is triggered whenever the auctionDuration is changed.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`newValue`| uint128 | The new value of auctionDuration.
### AuctionExtended
```solidity
  event AuctionExtended(
    uint256 tokenId,
    uint256 endTime
  )
```
This event is triggered whenever an auction's end time is extended.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`tokenId`| uint256 | The id of the token being bid on.
|`endTime`| uint256 | The time that the auction is scheduled to end.
### AuctionSettled
```solidity
  event AuctionSettled(
    uint256 tokenId,
    address bidder,
    uint256 amount
  )
```
This event is triggered whenever a call to {settleAuction} succeeds.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`tokenId`| uint256 | The id of the token being bid on.
|`bidder`| address | The address that received the tokens.
|`amount`| uint256 | The amount of tokens the address received.
### Bid
```solidity
  event Bid(
    uint256 tokenId,
    address bidder,
    uint256 amount
  )
```
This event is triggered whenever a call to {bid} succeeds.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`tokenId`| uint256 | The id of the token being bid on.
|`bidder`| address | The address that received the tokens.
|`amount`| uint256 | The amount of tokens the address received.
### MinimumPercentageIncreasex100Changed
```solidity
  event MinimumPercentageIncreasex100Changed(
    uint128 newValue
  )
```
This event is triggered whenever the minimumPercentageIncreasex100 is changed.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`newValue`| uint128 | The new value of minimumPercentageIncreasex100.
### StartingPriceChanged
```solidity
  event StartingPriceChanged(
    uint128 newValue
  )
```
This event is triggered whenever the startingPrice is changed.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`newValue`| uint128 | The new value of startingPrice.
### TimeBufferChanged
```solidity
  event TimeBufferChanged(
    uint128 newValue
  )
```
This event is triggered whenever the timeBuffer is changed.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`newValue`| uint128 | The new value of timeBuffer.



## Structs
### AuctionConfig
```solidity
  struct AuctionConfig{
    uint128 startingPrice;
    uint128 auctionDuration;
    uint128 timeBuffer;
    uint128 minimumPercentageIncreasex100;
  }
```
### AuctionState
```solidity
  struct AuctionState{
    uint256 bidAmount;
    uint128 startTime;
    uint128 endTime;
    address bidder;
  }
```

