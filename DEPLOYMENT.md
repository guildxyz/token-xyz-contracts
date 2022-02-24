# Deployment instructions - Extended version

Step-by-step instructions on how to deploy the full contract set on a network. We will use _ropsten_ in this example, but the process is the same for any supported network.

## Initial migration

First deploy InitialMigration and TokenXyz (with InitialMigration's address served as the bootstrapper address in it's constructor - edit migrations/2_main_migration for this), then deploy the features defined in InitialMigration.

```sh
truffle migrate --network ropsten -f 2 --to 2
truffle run verify --network ropsten InitialMigration
truffle run verify --network ropsten TokenXyz
truffle migrate --network ropsten -f 3 --to 3
truffle run verify --network ropsten SimpleFunctionRegistryFeature
truffle run verify --network ropsten OwnableFeature
```

Next, call initializeTokenXyz(...) on InitialMigration, with the deployed features' addresses supplied as the last parameter. Order matters here.

## Adding new feature contracts or updating existing ones

### Allowed storage changes on updates

The safest is to add more variables to the last position. However, some other actions should work too:

- fixed size types:
  - replace variables: will return corrupt values until they are re-set. After that they work as usual. Need to verify that they fit in the same storage slot as the previous variable - or have the same size if they were packed.
- dynamic size types:
  - replace them with fixed size types (note: this will still leave the old data on random slots but that should not cause issues)
  - replace strings with bytes (dynamic size) and vica versa
  - modify values of mappings/arrays of fixed type - same as replacing variables above
  - modify values of mappings/arrays of complex type (struct, i.e. modifying the struct) - works, returns the correct values for unmodified elements and zero for newly added ones
  - change the type of the keys of mappings - works, however probably it's not a good idea to do this as previous data will appear under keys that might not make sense anymore

### Before deployment

If you are adding a new feature contract, ensure you have completed all these steps:

- added the new contract's name to the StorageId enum in _storage/LibStorage.sol_
- created a new library for accessing it's storage in the _storage_ folder. It's contents should be analogous to the other contracts' files
- created the contract's interface in _features/interfaces_
- imported the interface in ITokenXyz.sol and made it inherit from that
- the new feature:
  - extends IFeature, FixinCommon and it's own interface
  - implements a migrate() function that registers it's function selectors and returns LibMigrate.MIGRATE_SUCCESS

If you are updating an already deployed feature, ensure you have done these steps prior to deployment:

- appended storage variables in their Lib...Storage library
- updated the migrate() function to register any new function selector(s)
- updated their interface
- (optional) updated FEATURE_VERSION

### Deployment & migration

To extend the contracts with a new feature contract, deploy it first.

Let's say we want to add a new feature called TestFeature and added a 4th migration script for it:

```sh
truffle migrate --network ropsten -f 4 --to 4
truffle run verify --network ropsten TestFeature
```

As a last step, call migrate() on TokenXyz. Simple node.js code to demonstrate this:

```js
const tokenXyzAddress = "0x..."; // Address of the TokenXyz contract
const newFeatureAddress = "0x..."; // Address of the feature we just deployed
const wallet = await walletManager.fromMnemonic("ropsten"); // A wallet connected to a provider. Not including the boilerplate code here

const entry = new ethers.Contract(tokenXyzAddress, ITokenXyzAbi, wallet);

const migrateInterface = new ethers.utils.Interface(ITokenXyzAbi);
const migrateCallData = migrateInterface.encodeFunctionData("migrate()");

await entry["migrate(address,bytes,address)"](newFeatureAddress, migrateCallData, wallet.address);
```

Note: to call any newly added functions on the contract, don't forget to update update the TokenXyz contract's ABI - for which you should use the ABI from it's interface (ITokenXyz).
