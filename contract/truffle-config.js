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