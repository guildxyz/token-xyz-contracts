# ERC721Curve

An NFT with an ever increasing price along a curve.

## Functions

### constructor

```solidity
  constructor(
    string name,
    string symbol,
    string cid_,
    uint256 maxSupply_,
    uint256 startingPrice_,
    address owner
  )
```

Sets metadata, config and transfers ownership to `owner`.

#### Parameters:

| Name             | Type    | Description                                                    |
| :--------------- | :------ | :------------------------------------------------------------- |
| `name`           | string  | The name of the token.                                         |
| `symbol`         | string  | The symbol of the token.                                       |
| `cid_`           | string  | The ipfs hash, under which the off-chain metadata is uploaded. |
| `maxSupply_`     | uint256 | The maximum number of NFTs that can ever be minted.            |
| `startingPrice_` | uint256 | The price of the first token in wei.                           |
| `owner`          | address | The owner address: will be able to withdraw collected fees.    |

### getPriceOf

```solidity
  function getPriceOf(
    uint256 tokenId
  ) public returns (uint256 price)
```

Gets the price of a specific token.

#### Parameters:

| Name      | Type    | Description          |
| :-------- | :------ | :------------------- |
| `tokenId` | uint256 | The ID of the token. |

#### Return Values:

| Name    | Type    | Description                    |
| :------ | :------ | :----------------------------- |
| `price` | uint256 | The price of the token in wei. |

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

Sends the collected funds to `recipient`. Callable only by the owner.

#### Parameters:

| Name        | Type            | Description                       |
| :---------- | :-------------- | :-------------------------------- |
| `recipient` | address payable | The address receiving the tokens. |

### tokenURI

```solidity
  function tokenURI(
    uint256 tokenId
  ) public returns (string)
```

Returns the Uniform Resource Identifier (URI) for `tokenId` token.

#### Parameters:

| Name      | Type    | Description          |
| :-------- | :------ | :------------------- |
| `tokenId` | uint256 | The id of the token. |

### totalSupply

```solidity
  function totalSupply(
  ) public returns (uint256 count)
```

The total amount of tokens stored by the contract.

#### Return Values:

| Name    | Type | Description         |
| :------ | :--- | :------------------ |
| `count` |      | The number of NFTs. |

## State variables

```solidity
  uint256 maxSupply;

  uint256 startingPrice;

  string cid;

  struct Counters.Counter tokenIdCounter;
```
