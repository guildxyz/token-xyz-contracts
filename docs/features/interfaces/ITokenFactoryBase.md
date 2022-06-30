# ITokenFactoryBase

Common functions and events for a contract that deploys ERC20 token contracts for anyone.

## Functions

### getDeployedTokens

```solidity
  function getDeployedTokens(
    string urlName
  ) external returns (struct IFactoryFeature.DeployData[] tokenAddresses)
```

Returns all the deployed token addresses by a specific creator.

#### Parameters:

| Name      | Type   | Description                                                      |
| :-------- | :----- | :--------------------------------------------------------------- |
| `urlName` | string | The url name used by the frontend, kind of an id of the creator. |

#### Return Values:

| Name             | Type   | Description                             |
| :--------------- | :----- | :-------------------------------------- |
| `tokenAddresses` | string | The requested array of token addresses. |

## Events

### TokenAdded

```solidity
  event TokenAdded(
    address deployer,
    string urlName,
    address token,
    uint96 factoryVersion
  )
```

Event emitted when creating a token.

The deployer and factoryversion params are 0 if the token was added manually.

#### Parameters:

| Name             | Type    | Description                                                             |
| :--------------- | :------ | :---------------------------------------------------------------------- |
| `deployer`       | address | The address which created the token.                                    |
| `urlName`        | string  | The urlName, where the created token is sorted in.                      |
| `token`          | address | The address of the newly created token.                                 |
| `factoryVersion` | uint96  | The version number of the factory that was used to deploy the contract. |
