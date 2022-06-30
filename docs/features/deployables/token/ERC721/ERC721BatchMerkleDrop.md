# ERC721BatchMerkleDrop

Provides ERC721 token minting with amount restricted based on a Merkle tree.



## Functions
### constructor
```solidity
  constructor(
    string name,
    string symbol,
    string cid_,
    uint256 maxSupply_,
    bytes32 merkleRoot_,
    uint256 distributionDuration,
    address owner
  ) 
``` 
Sets metadata, drop config and transfers ownership to `owner`.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`name` | string | The name of the token.
|`symbol` | string | The symbol of the token.
|`cid_` | string | The ipfs hash, under which the off-chain metadata is uploaded.
|`maxSupply_` | uint256 | The maximum number of NFTs that can ever be minted.
|`merkleRoot_` | bytes32 | The root of the Merkle tree generated from the distribution list.
|`distributionDuration` | uint256 | The time interval while the distribution lasts in seconds.
|`owner` | address | The owner address: will be able to mint tokens after `distributionDuration` ends.

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
Sets token(s) on `index` as claimed.



### isClaimed
```solidity
  function isClaimed(
    uint256 index
  ) public returns (bool claimed)
``` 
Returns true if the index has been marked claimed.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`index` | uint256 | A value from the generated input list.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`claimed`| uint256 | Whether the tokens from `index` have been claimed.
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
