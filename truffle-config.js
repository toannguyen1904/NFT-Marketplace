module.exports = {
  networks: {
    development: {
    host: "127.0.0.1",     // Localhost (default: none)
    port: 7545,            // Standard Ethereum port (default: none)
    network_id: "*",       // Any network (default: none)
    //from: '0xdACF44b182E69a2717d78D0BEDB0F6c0393B8980'
    },
  },

  contracts_directory: './src/contracts/',
  contracts_build_directory: './src/abis',

  compilers: {
    solc: {
      version: "^0.8.0",
      optimizer:{
        enabled: 'true',
        runs: 200
      }
    }
  },
};