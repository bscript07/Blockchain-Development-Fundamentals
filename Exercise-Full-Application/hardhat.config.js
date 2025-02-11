require('@nomicfoundation/hardhat-toolbox');
require('@nomicfoundation/hardhat-verify');
require('dotenv').config();
require('./tasks');

const SEPOLIA_API_KEY = process.env.SEPOLIA_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: '0.8.28',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${SEPOLIA_API_KEY}`,
      accounts: [PRIVATE_KEY],
      timeout: 200000,
    },
  },
  etherscan: {
    apiKey: {
      sepolia: ETHERSCAN_API_KEY,
    },
  },
  sourcify: {
    enabled: true,
  },
};

// Crowdsale contract address: 0xC3b6dD962c2ffBdcc66d38E5a90a177FD78B3c46
// BitOrangeToken contract address: 0xD5F7cC2903a76D3926B2bb98BC715D9ee5B63107

// 1 - npx hardhat verify --network sepolia <CONTRACT_ADDRESS> <YOUR_OWNER_ADDRESS_HERE>
// 2 - npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
