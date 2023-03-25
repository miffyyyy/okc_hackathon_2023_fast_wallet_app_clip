require('dotenv').config();
const mnemonic = process.env.MNEMONIC;
const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  development: {
    host: "127.0.0.1", // Localhost (default: none)
    port: 9545, // Standard Ethereum port (default: none)
    network_id: "*", // Any network (default: none)
},
  networks: {
    goerli: {
      provider: () =>
        new HDWalletProvider({
          mnemonic: process.env.MNEMONIC,
          providerOrUrl: process.env.GOERLI_RPC_URL,
        }),
      network_id: 5,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
  },
  compilers: {
    solc: {
      version: "0.8.17", 
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
};