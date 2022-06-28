# IERC721MerkleDrop

Allows anyone to mint a non-fungible token if they exist in a Merkle root.



## Functions
### maxSupply
```solidity
  function maxSupply(
  ) external returns (uint256)
```
The maximum number of NFTs that can ever be minted.



### totalSupply
```solidity
  function totalSupply(
  ) external returns (uint256)
```
The total amount of tokens stored by the contract.



### merkleRoot
```solidity
  function merkleRoot(
  ) external returns (bytes32)
```
Returns the Merkle root of the Merkle tree containing account balances available to claim.



### distributionEnd
```solidity
  function distributionEnd(
  ) external returns (uint256)
```
Returns the unix timestamp that marks the end of the token distribution.



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






