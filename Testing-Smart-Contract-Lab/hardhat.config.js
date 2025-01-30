require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28", // Ensure your Solidity version matches your contract
  networks: {
    hardhat: {
      chainId: 1337, // Make sure this is set for local testing
    },
  },
  mocha: {
    timeout: 20000,
  },
};
