require('dotenv').config();
const mnemonic = process.env.MNEMONIC;
const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  networks: {
    oktestnet: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          "https://exchaintestrpc.okex.org"
        ),
      network_id: 65,
      gas: 3000000,
      gasPrice: 20000000000,
    },
  },
  compilers: {
    solc: {
      version: "^0.8.0", 
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
};