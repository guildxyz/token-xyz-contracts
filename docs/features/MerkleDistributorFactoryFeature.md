


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
### createAirdrop
```solidity
  function createAirdrop(
    string urlName,
    address token,
    bytes32 merkleRoot,
    uint256 distributionDuration,
    address owner
  ) external
```
Deploys a new Merkle Distributor contract.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`urlName` | string | The url name used by the frontend, kind of an id of the creator.
|`token` | address | The address of the token to distribute.
|`merkleRoot` | bytes32 | The root of the Merkle tree generated from the distribution list.
|`distributionDuration` | uint256 | The time interval while the distribution lasts in seconds.
|`owner` | address | The owner address of the contract to be deployed. Will have special access to some functions.

### getDeployedAirdrops
```solidity
  function getDeployedAirdrops(
    string urlName
  ) external returns (struct IFactoryFeature.DeployData[] airdropAddresses)
```
Returns all the deployed airdrop contract addresses by a specific creator.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`urlName` | string | The url name used by the frontend, kind of an id of the creator.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`airdropAddresses`| string | The requested array of contract addresses.
