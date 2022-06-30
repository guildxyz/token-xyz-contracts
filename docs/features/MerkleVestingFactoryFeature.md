# MerkleVestingFactoryFeature

A contract that deploys token vesting contracts for anyone.

## Functions

### migrate

```solidity
  function migrate(
  ) external returns (bytes4 success)
```

Initialize and register this feature. Should be delegatecalled by `Migrate.migrate()`.

#### Return Values:

| Name      | Type | Description                      |
| :-------- | :--- | :------------------------------- |
| `success` |      | `LibMigrate.SUCCESS` on success. |

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

| Name      | Type    | Description                                                                                   |
| :-------- | :------ | :-------------------------------------------------------------------------------------------- |
| `urlName` | string  | The url name used by the frontend, kind of an id of the creator.                              |
| `token`   | address | The address of the token to distribute.                                                       |
| `owner`   | address | The owner address of the contract to be deployed. Will have special access to some functions. |

### getDeployedVestings

```solidity
  function getDeployedVestings(
    string urlName
  ) external returns (struct IFactoryFeature.DeployData[] vestingAddresses)
```

Returns all the deployed vesting contract addresses by a specific creator.

#### Parameters:

| Name      | Type   | Description                                                      |
| :-------- | :----- | :--------------------------------------------------------------- |
| `urlName` | string | The url name used by the frontend, kind of an id of the creator. |

#### Return Values:

| Name               | Type   | Description                                |
| :----------------- | :----- | :----------------------------------------- |
| `vestingAddresses` | string | The requested array of contract addresses. |

## State variables

```solidity
  string FEATURE_NAME;

  uint96 FEATURE_VERSION;
```
