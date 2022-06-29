# IERC721MerkleDrop

Allows anyone to mint a non-fungible token if they exist in a Merkle root.



## Functions
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
### merkleRoot
```solidity
  function merkleRoot(
  ) external returns (bytes32 root)
```
Returns the Merkle root of the Merkle tree containing account balances available to claim.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`root`|  | The root hash of the Merkle tree.
### distributionEnd
```solidity
  function distributionEnd(
  ) external returns (uint256 unixSeconds)
```
Returns the unix timestamp that marks the end of the token distribution.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`unixSeconds`|  | The unix timestamp in seconds.
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






