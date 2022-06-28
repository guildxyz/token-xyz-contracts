# ERC721BatchMerkleDrop

Allows anyone to mint a certain amount of this token if they exist in a Merkle root.



## Functions
### constructor
```solidity
  function constructor(
  ) public
```




### claim
```solidity
  function claim(
    uint256 index,
    address account,
    uint256 amount,
    bytes32[] merkleProof
  ) external
```
Claims tokens to the given address. Reverts if the inputs are invalid.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`index` | uint256 | A value from the generated input list.
|`account` | address | A value from the generated input list.
|`amount` | uint256 | A value from the generated input list.
|`merkleProof` | bytes32[] | An array of values from the generated input list.

### safeMint
```solidity
  function safeMint(
    address to
  ) external
```
Mint the next token to the given address.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`to` | address | The address receiving the token.

### safeBatchMint
```solidity
  function safeBatchMint(
    address to,
    uint256 amount
  ) external
```
Mint a certain amount of tokens to the given address.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`to` | address | The address receiving the tokens.
|`amount` | uint256 | The amount of tokens to mint.

### _safeBatchMint
```solidity
  function _safeBatchMint(
  ) internal
```




### _setClaimed
```solidity
  function _setClaimed(
  ) internal
```




### isClaimed
```solidity
  function isClaimed(
    uint256 index
  ) public returns (bool)
```
Returns true if the index has been marked claimed.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`index` | uint256 | A value from the generated input list.

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

