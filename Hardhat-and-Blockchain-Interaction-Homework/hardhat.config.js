require("@nomicfoundation/hardhat-toolbox");

require("./tasks/01_DeployContract");
require("./tasks/02_MintTokens");
require("./tasks/03_TransferTokens");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
  },
};
