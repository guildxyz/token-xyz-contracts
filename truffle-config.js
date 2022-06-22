/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * truffleframework.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like truffle-hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura API
 * keys are available for free at: infura.io/register
 *
 */
const HDWalletProvider = require("@truffle/hdwallet-provider");
require("dotenv").config();

module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */
  networks: {
    // Useful for testing. The `development` name is special - truffle uses it by default
    // if it's defined here and no other network is specified at the command line.
    // You should run a client (like ganache-cli, geth or parity) in a separate terminal
    // tab if you use this network and you must also set the `host`, `port` and `network_id`
    // options below to some value.
    development: {
      host: "127.0.0.1", // Localhost (default: none)
      port: 8545, // Standard port (default: none)
      network_id: "*" // Any network (default: none)
    },
    ethereum: {
      provider: () =>
        new HDWalletProvider({
          privateKeys: [process.env.PRIVATE_KEY],
          providerOrUrl: `wss://mainnet.infura.io/ws/v3/${process.env.INFURA_ID}`,
          chainId: 1
        }),
      network_id: 1,
      confirmations: 2,
      networkCheckTimeout: 9000000,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    goerli: {
      provider: () =>
        new HDWalletProvider({
          privateKeys: [process.env.PRIVATE_KEY],
          providerOrUrl: `wss://goerli.infura.io/ws/v3/${process.env.INFURA_ID}`,
          chainId: 5
        }),
      network_id: 5,
      confirmations: 1,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    kovan: {
      provider: () =>
        new HDWalletProvider({
          privateKeys: [process.env.PRIVATE_KEY],
          providerOrUrl: `wss://kovan.infura.io/ws/v3/${process.env.INFURA_ID}`,
          chainId: 42
        }),
      network_id: 42,
      confirmations: 2,
      networkCheckTimeout: 90000,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    ropsten: {
      provider: () =>
        new HDWalletProvider({
          privateKeys: [process.env.PRIVATE_KEY],
          providerOrUrl: `wss://ropsten.infura.io/ws/v3/${process.env.INFURA_ID}`,
          chainId: 3
        }),
      network_id: 3, // Ropsten's id
      confirmations: 1, // # of confs to wait between deployments. (default: 0)
      networkCheckTimeout: 90000, // Seems like the default value was not enough
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true // Skip dry run before migrations? (default: false for public nets )
    },
    bsc: {
      provider: () =>
        new HDWalletProvider({
          privateKeys: [process.env.PRIVATE_KEY],
          providerOrUrl: `https://bsc-dataseed1.binance.org`,
          chainId: 56
        }),
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    bsctest: {
      provider: () =>
        new HDWalletProvider({
          privateKeys: [process.env.PRIVATE_KEY],
          providerOrUrl: `https://data-seed-prebsc-1-s1.binance.org:8545`,
          chainId: 97
        }),
      network_id: 97,
      confirmations: 10,
      networkCheckTimeout: 5000,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    polygon: {
      provider: () =>
        new HDWalletProvider({
          privateKeys: [process.env.PRIVATE_KEY],
          providerOrUrl: `wss://ws-matic-mainnet.chainstacklabs.com`,
          chainId: 137
        }),
      network_id: 137,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    mumbai: {
      provider: () =>
        new HDWalletProvider({
          privateKeys: [process.env.PRIVATE_KEY],
          providerOrUrl: `https://rpc-mumbai.matic.today`,
          chainId: 80001
        }),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    reporter: "eth-gas-reporter",
    reporterOptions: {
      showTimeSpent: true
    }
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.15", // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {
        // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200
        }
        //  evmVersion: "byzantium"
      }
    }
  },

  plugins: ["truffle-plugin-verify"],

  // This is just for the `truffle-plugin-verify` to catch the API key
  api_keys: {
    etherscan: process.env.ETHERSCAN_API
  }
};
