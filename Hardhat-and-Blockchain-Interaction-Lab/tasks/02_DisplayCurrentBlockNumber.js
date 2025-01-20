const { task } = require("hardhat/config");

task("displayBlock", "Fetches and display the current block number").setAction(
  async (_, hre) => {
    const { ethers } = hre; // Destructure ethers from hre (Hardhat Runtime Environment)

    try {
      const blockNumber = await ethers.provider.getBlockNumber();
      console.log(`Current block number: ${blockNumber}`);
    } catch (error) {
      console.log("Error fetching the block number", error);
    }
  }
  
);

module.exports = {};
