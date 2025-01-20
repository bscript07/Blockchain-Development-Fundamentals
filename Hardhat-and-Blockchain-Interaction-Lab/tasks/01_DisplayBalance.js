const { task } = require("hardhat/config");

task("displayBalance", "Display the ethers balance of the first account")
.setAction(async(_, hre) => {
    const {ethers} = hre; // Destructure ethers from hre (Hardhat Runtime Environment)
    const [firstAccount] = await ethers.getSigners();
    const balance = await ethers.provider.getBalance(firstAccount.address);
    console.log(`01_DisplayBalance task loaded successfully ${balance}`);

    // console.log(`Balance of ${firstAccount.address}: ${ethers.utils.formatEther(balance)} ETH`);
    
})

module.exports = {};