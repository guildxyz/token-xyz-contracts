# Token.xyz smart contracts

The smart contracts in this repository are the core of token.xyz.

Detailed documentation can be found in the _[docs](docs)_ folder.

## Setup

To run the project you need:

- [Node.js](https://nodejs.org/en/download) development environment (version 14 or newer).
- [Truffle](https://www.trufflesuite.com/truffle) for compiling, deploying and testing (version 5.4.30 or newer).
- [Ganache](https://github.com/trufflesuite/ganache/releases) environment for local testing (version 7.6.0 or newer).

Pull the repository from GitHub, then install its dependencies by executing this command:

```bash
npm install
```

Certain actions, like deploying to a public network or verifying source code on block explorers, need environment variables in a file named `.env`. See _[.env.example](.env.example)_ for more info.

## Deployment

To deploy the smart contracts to a network, replace _[networkName]_ in this command:

```bash
truffle migrate --network [networkName]
```

Networks can be configured in _[truffle-config.js](truffle-config.js)_. We've preconfigured the following:

- `development` (for local testing)
- `ethereum` (Ethereum Mainnet)
- `goerli` (Görli Ethereum Testnet)
- `kovan` (Kovan Ethereum Testnet)
- `rinkeby` (Rinkeby Ethereum Testnet)
- `ropsten` (Ropsten Ethereum Testnet)
- `bsc` (BNB Smart Chain)
- `bsctest` (BNB Smart Chain Testnet)
- `polygon` (Polygon Mainnet (formerly Matic))
- `mumbai` (Matic Mumbai Testnet)
- `gnosis` (Gnosis Chain (formerly xDai Chain))

### Note

The above procedure deploys all the contracts. If you want to deploy only specific contracts, you can run only the relevant script(s) via the below command:

```bash
truffle migrate -f [start] --to [end] --network [name]
```

Replace _[start]_ with the number of the first and _[end]_ with the number of the last migration script you wish to run. To run only one script, _[start]_ and _[end]_ should match. The numbers of the scripts are:

- 1 - Migrations (Truffle feature, optional)
- 2 - Full- or InitialMigration & TokenXyz
- 3 - SimpleFunctionRegistryFeature & OwnableFeature & MulticallFeature
- 4 - TokenFactoryFeature & TokenWithRolesFactoryFeature
- 5 - MerkleDistributorFactoryFeature
- 6 - MerkleVestingFactoryFeature
- 7 - ERC721MerkleDropFactoryFeature
- 8 - ERC721CurveFactoryFeature
- 9 - ERC721AuctionFactoryFeature

### Extended instructions

For more detailed instructions, see [the extended version of the deployment instructions](./DEPLOYMENT.md).

## Verification

For automatic verification you can use [truffle-plugin-verify](https://github.com/rkalis/truffle-plugin-verify).

```bash
truffle run verify [contractName] --network [networkName]
```

## Linting

The project uses [Solhint](https://github.com/protofire/solhint). To run it, simply execute:

```bash
npm run lint
```

## Tests

To run the unit tests written for this project, execute this command in a terminal:

```bash
npm test
```

To run the unit tests only in a specific file, just append the path to the command. For example, to run tests just for TokenFactory:

```bash
npm test ./test/TokenFactoryTest.js
```

## Documentation

The documentation for the contracts is generated via the [solidity-docgen](https://github.com/OpenZeppelin/solidity-docgen/tree/0.5) package. Run the tool via the following command:

```bash
npm run docgen
```

The output can be found in the _[docs](docs)_ folder.
