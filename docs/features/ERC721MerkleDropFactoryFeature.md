


## Functions
### migrate
```solidity
  function migrate(
  ) external returns (bytes4 success)
```
Initialize and register this feature. Should be delegatecalled by `Migrate.migrate()`.



#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`success`|  | `LibMigrate.SUCCESS` on success.
### createNFTMerkleDrop
```solidity
  function createNFTMerkleDrop(
    string urlName,
    bytes32 merkleRoot,
    uint256 distributionDuration,
    struct IERC721FactoryCommon.NftMetadata nftMetadata,
    bool specificIds,
    address owner
  ) external
```
Deploys a new NFT Merkle Drop contract.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`urlName` | string | The url name used by the frontend, kind of an id of the creator.
|`merkleRoot` | bytes32 | The root of the Merkle tree generated from the distribution list.
|`distributionDuration` | uint256 | The time interval while the distribution lasts in seconds.
|`nftMetadata` | struct IERC721FactoryCommon.NftMetadata | The basic metadata of the NFT that will be created.
|`specificIds` | bool | If true: the tokenIds, else: the amount of tokens per user will be specified.
|`owner` | address | The owner address of the contract to be deployed. Will have special access to some functions.

### getDeployedNFTMerkleDrops
```solidity
  function getDeployedNFTMerkleDrops(
    string urlName
  ) external returns (struct IFactoryFeature.DeployData[] nftAddresses)
```
Returns all the deployed contract addresses by a specific creator.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`urlName` | string | The url name used by the frontend, kind of an id of the creator.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`nftAddresses`| string | The requested array of contract addresses.
