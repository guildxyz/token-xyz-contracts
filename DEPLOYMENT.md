# Deployment instructions - Extended version

Step-by-step instructions on how to deploy the full contract set on a network. We will use _goerli_ in this example, but the process is the same for any supported network.

## First migration

First, decide the way you migrate the contracts. There are two possibilities: to deploy everything and initialize them at once using the FullMigration contract (it will need changes if any new features were added), or to deploy just the most important contracts and deal with the rest later (use InitialMigration in this case). Choose whichever method suits you best.  
Note: to choose the migration contract and to specify the initializeCaller address, you'll have to edit _migrations/2_main_migration.js_.

### InitialMigration

Deploy InitialMigration and TokenXyz, then deploy the defined features (SimpleFunctionRegistry and Ownable). Run the following command:

```sh
truffle migrate --network goerli -f 2 --to 3
```

Next, call the initializer function on InitialMigration, called initializeTokenXyz(...), with the deployed features' addresses supplied as the last parameter. Order matters here. You should initiate the transaction from the initializeCaller address to succeed.

### FullMigration

Deploy FullMigration and TokenXyz, then deploy the defined features. Replace _[lastMigrationScript]_ in the following command with the number of the migration script you last want to run (make sure they deploy all contracts defined in FullMigration):

```sh
truffle migrate --network goerli -f 2 --to [lastMigrationScript]
```

Next, call the initializer function on FullMigration, called migrateTokenXyz(...), with the deployed features' addresses supplied as the last parameter. Order matters here. You should initiate the transaction from the initializeCaller address to succeed.

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
- updated the FullMigration contract to really be full again
- made sure there is a Truffle migration script that would deploy it
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

Let's say we want to add a new feature called TestFeature and added migration script number 42 for it:

```sh
truffle migrate --network goerli -f 42 --to 42
```

As a last step, call migrate() on TokenXyz. Simple node.js code to demonstrate this:

```js
const tokenXyzAddress = "0x..."; // Address of the TokenXyz contract
const newFeatureAddress = "0x..."; // Address of the feature we just deployed
const wallet = await walletManager.fromMnemonic("goerli"); // A wallet connected to a provider. Not including the boilerplate code here

const entry = new ethers.Contract(tokenXyzAddress, ITokenXyzAbi, wallet);

const migrateInterface = new ethers.utils.Interface(["function migrate()"]);
const migrateCallData = migrateInterface.encodeFunctionData("migrate()");

await entry["migrate(address,bytes,address)"](newFeatureAddress, migrateCallData, wallet.address);
```

Note: to call any newly added functions on the contract, don't forget to update update the TokenXyz contract's ABI - for which you should use the ABI from it's interface (ITokenXyz).
