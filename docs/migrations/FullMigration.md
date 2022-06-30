# FullMigration

A contract for deploying and configuring the full TokenXyz contract.

## Functions

### constructor

```solidity
  constructor(
    address payable initializeCaller_
  )
```

Instantiate this contract and set the allowed caller of `initializeTokenXyz()` to `initializeCaller`.

#### Parameters:

| Name                | Type            | Description                                   |
| :------------------ | :-------------- | :-------------------------------------------- |
| `initializeCaller_` | address payable | The allowed caller of `initializeTokenXyz()`. |

### getBootstrapper

```solidity
  function getBootstrapper(
  ) external returns (address bootstrapper)
```

Retrieve the bootstrapper address to use when constructing `TokenXyz`.

#### Return Values:

| Name           | Type | Description               |
| :------------- | :--- | :------------------------ |
| `bootstrapper` |      | The bootstrapper address. |

### migrateTokenXyz

```solidity
  function migrateTokenXyz(
    address payable owner,
    contract TokenXyz tokenXyz,
    struct FullMigration.Features features
  ) public returns (contract TokenXyz _tokenXyz)
```

Initialize the `TokenXyz` contract with the full feature set,
transfer ownership to `owner`, then self-destruct.

#### Parameters:

| Name       | Type              | Description                                            |
| :--------- | :---------------- | :----------------------------------------------------- |
| `owner`    | address payable   | The owner of the contract.                             |
| `tokenXyz` | contract TokenXyz | The instance of the TokenXyz contract. TokenXyz should |

       been constructed with this contract as the bootstrapper.

|`features` | struct FullMigration.Features | Features to add to the proxy.

#### Return Values:

| Name        | Type            | Description                                                         |
| :---------- | :-------------- | :------------------------------------------------------------------ |
| `_tokenXyz` | address payable | The configured TokenXyz contract. Same as the `tokenXyz` parameter. |

### die

```solidity
  function die(
    address payable ethRecipient
  ) external
```

Destroy this contract. Only callable from ourselves (from `initializeTokenXyz()`).

#### Parameters:

| Name           | Type            | Description                           |
| :------------- | :-------------- | :------------------------------------ |
| `ethRecipient` | address payable | Receiver of any ETH in this contract. |

## Structs

### Features

```solidity
  struct Features{
    contract SimpleFunctionRegistryFeature registry;
    contract OwnableFeature ownable;
    contract MulticallFeature multicall;
    contract TokenFactoryFeature tokenFactory;
    contract TokenWithRolesFactoryFeature tokenWithRolesFactory;
    contract MerkleDistributorFactoryFeature merkleDistributorFactory;
    contract MerkleVestingFactoryFeature merkleVestingFactory;
    contract ERC721MerkleDropFactoryFeature erc721MerkleDropFactory;
    contract ERC721CurveFactoryFeature erc721CurveFactory;
    contract ERC721AuctionFactoryFeature erc721AuctionFactory;
  }
```

## State variables

```solidity
  address initializeCaller;
```
