# IERC721CurveFactoryFeature

A contract that deploys special ERC721 contracts for anyone.



## Functions
### createNFTWithCurve
```solidity
  function createNFTWithCurve(
    string urlName,
    struct IERC721FactoryCommon.NftMetadata nftMetadata,
    uint256 startingPrice,
    address owner
  ) external
```
Deploys a new ERC721Curve contract.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`urlName` | string | The url name used by the frontend, kind of an id of the creator.
|`nftMetadata` | struct IERC721FactoryCommon.NftMetadata | The basic metadata of the NFT that will be created (name, symbol, ipfsHash, maxSupply).
|`startingPrice` | uint256 | The price of the first token that will be minted.
|`owner` | address | The owner address of the contract to be deployed. Will have special access to some functions.

### getDeployedNFTsWithCurve
```solidity
  function getDeployedNFTsWithCurve(
    string urlName
  ) external returns (struct IFactoryFeature.DeployData[] nftAddresses)
```
Returns all the deployed ERC721Curve contract addresses by a specific creator.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`urlName` | string | The url name used by the frontend, kind of an id of the creator.

#### Return Values:
| Name                           | Type          | Description                                                                  |
| :----------------------------- | :------------ | :--------------------------------------------------------------------------- |
|`nftAddresses`| string | The requested array of contract addresses.

## Events
### ERC721CurveDeployed
```solidity
  event ERC721CurveDeployed(
    address deployer,
    string urlName,
    address instance,
    uint96 factoryVersion
  )
```
Event emitted when creating a new ERC721Curve contract.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`deployer`| address | The address which created the contract.
|`urlName`| string | The urlName, where the created contract is sorted in.
|`instance`| address | The address of the newly created contract.
|`factoryVersion`| uint96 | The version number of the factory that was used to deploy the contract.




