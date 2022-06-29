# ERC721MerkleDrop

Allows anyone to mint a token with a specific ID if they exist in a Merkle root.



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
    address to,
    uint256 tokenId
  ) external
```
Mint a token to the given address.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`to` | address | The address receiving the token.
|`tokenId` | uint256 | The id of the token to be minted.

### _safeMint
```solidity
  function _safeMint(
  ) internal
```
An optimized version of {_safeMint} using custom errors.



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
  bytes32 merkleRoot;

  uint256 distributionEnd;

  uint256 maxSupply;

  uint256 totalSupply;

  string cid;
```
