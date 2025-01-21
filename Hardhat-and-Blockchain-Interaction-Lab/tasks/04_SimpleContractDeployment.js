const { task } = require("hardhat/config");

task("deploySimpleContract", "Deploy a simple contract")
.setAction(async(_, hre) => {
    const {ethers} = hre;

        const [deployer] = await ethers.getSigners();
        console.log(`Deploying contract with the account: ${deployer.address}`);

        const Greeter = await ethers.getContractFactory("Greeter"); // Instance of Greeter contract
        const greeter = await Greeter.deploy("Hello, Hardhat!"); // Deploy Greeter contract 
        
        await greeter.deploymentTransaction().wait();
        console.log("Greeter contract deployed successfully");
        
});

module.exports = {};
