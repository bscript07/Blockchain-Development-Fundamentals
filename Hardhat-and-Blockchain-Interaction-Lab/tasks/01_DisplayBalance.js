const { task } = require("hardhat/config");

task(
  "displayBalance",
  "Display the ethers balance of the first account"
).setAction(async (_, hre) => {
  const { ethers } = hre; // Destructure ethers from hre (Hardhat Runtime Environment)

  try {
    const [firstAccount] = await ethers.getSigners();
    const balance = await ethers.provider.getBalance(firstAccount.address);
    const formattedBalance = hre.ethers.utils.formatEther(balance);
    console.log(`Balance task loaded successfully ${formattedBalance}`);
  } catch (error) {
    console.log("Error fetching the block number", error);
  }

});

module.exports = {};
