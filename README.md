# Token.xyz smart contracts

The smart contracts in this repository are the core of token.xyz.

## Requirements

To run the project you need:

- [Node.js](https://nodejs.org) development environment.
- [Truffle](https://www.trufflesuite.com/truffle) for compiling, deploying and testing.
- (optional) A file named `.env`. An example can be found in the project's root folder. It should contain the following variables:

  ```bash
  # The private key of your wallet.
  PRIVATE_KEY=

  # Your infura.io project ID for deploying to Ethereum networks.
  INFURA_ID=

  # Your API key for verification.
  ETHERSCAN_API_KEY=
  ```

## Before deployment

Pull the repository from GitHub, then install its dependencies by executing this command:

```bash
npm install
```

## Deployment

To deploy the smart contracts to a network, replace _[networkName]_ in this command:

```bash
truffle migrate --network [networkName]
```

Networks can be configured in _truffle-config.js_. We've preconfigured the following:

- `development` (for local testing)
- `ethereum` (Ethereum Mainnet)
- `goerli` (Görli Ethereum Testnet)
- `kovan` (Kovan Ethereum Testnet)
- `ropsten` (Ropsten Ethereum Testnet)
- `bsc` (Binance Smart Chain)
- `bsctest` (Binance Smart Chain Testnet)
- `polygon` (Polygon Mainnet (formerly Matic))
- `mumbai` (Matic Mumbai Testnet)

### Note

The above procedure deploys all the contracts. If you want to deploy only specific contracts, you can run only the relevant script(s) via the below command:

```bash
truffle migrate -f [start] --to [end] --network [name]
```

Replace _[start]_ with the number of the first and _[end]_ with the number of the last migration script you wish to run. To run only one script, _[start]_ and _[end]_ should match. The numbers of the scripts are:

- 1 - Migrations
- 2 - InitialMigration & TokenXyz
- 3 - SimpleFunctionRegistryFeature & OwnableFeature
- 4 - TokenFactoryFeature

If the script fails before starting the deployment, you might need to run the first one, too.

### Extended instructions

For more detailed instructions, see [the extended version of the deployment instructions](./DEPLOYMENT.md).

## Verification

For automatic verification you can use [truffle plugin verify](https://github.com/rkalis/truffle-plugin-verify).

```bash
truffle run verify [contractName] --network [networkName]
```

## Tests

To run the unit tests written for this project, execute this command in a terminal:

```bash
npm test
```

To run the unit tests only in a specific file, just append the path to the command. For example, to run tests just for MyContract:

```bash
npm test ./test/MyContractTest.js
```
