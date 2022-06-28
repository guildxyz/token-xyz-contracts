# IMerkleVestingFactoryFeature

A contract that deploys token vesting contracts for anyone.



## Functions
### createVesting
```solidity
  function createVesting(
    string urlName,
    address token,
    address owner
  ) external
```
Deploys a new Merkle Vesting contract.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`urlName` | string | The url name used by the frontend, kind of an id of the creator.
|`token` | address | The address of the token to distribute.
|`owner` | address | The owner address of the contract to be deployed. Will have special access to some functions.

### getDeployedVestings
```solidity
  function getDeployedVestings(
    string urlName
  ) external returns (struct IFactoryFeature.DeployData[] vestingAddresses)
```
Returns all the deployed vesting contract addresses by a specific creator.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`urlName` | string | The url name used by the frontend, kind of an id of the creator.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`vestingAddresses`| string | The requested array of contract addresses.

## Events
### MerkleVestingDeployed
```solidity
  event MerkleVestingDeployed(
    address deployer,
    string urlName,
    address instance,
    uint96 factoryVersion
  )
```
Event emitted when creating a new vesting contract.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`deployer`| address | The address which created the vesting.
|`urlName`| string | The urlName, where the created vesting contract is sorted in.
|`instance`| address | The address of the newly created vesting contract.
|`factoryVersion`| uint96 | The version number of the factory that was used to deploy the contract.




