const { task } = require("hardhat/config");

task("deploy", "Deploys StakeX and StakedPool contracts").setAction(
  async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying contracts with account:", deployer.address);

    // Deploy StakeX contract
    const StakeX = await hre.ethers.getContractFactory("StakeX");
    const stakeX = await StakeX.deploy();
    await stakeX.waitForDeployment();
    console.log("StakeX deployed to:", await stakeX.getAddress());

    // Deploy StakedPool contract, passing StakeX contract address
    const StakingPool = await hre.ethers.getContractFactory("StakingPool");
    const stakedPool = await StakingPool.deploy(deployer.address);
    await stakedPool.waitForDeployment();
    console.log("StakedPool deployed to:", await stakedPool.getAddress());

    // Verify contracts if on Sepolia network
    if (hre.network.name === "sepolia") {
      console.log("\nVerifying contracts on Sepolia...");

      // Wait for a few block confirmations
      console.log("Waiting for block confirmations...");
      await stakeX.deploymentTransaction().wait(5); // Wait for 5 confirmations for StakeX
      await stakedPool.deploymentTransaction().wait(5); // Wait for 5 confirmations for StakedPool

      // Verify StakeX contract
      try {
        await hre.run("verify:verify", {
          address: await stakeX.getAddress(),
          constructorArguments: [],
        });
        console.log("StakeX verified successfully");
      } catch (error) {
        console.log("StakeX verification failed:", error.message);
      }

      // Verify StakedPool contract
      try {
        await hre.run("verify:verify", {
          address: await stakedPool.getAddress(),
          constructorArguments: [deployer.address],
        });
        console.log("StakedPool verified successfully");
      } catch (error) {
        console.log("StakedPool verification failed:", error.message);
      }
    }

    // Deployment Summary
    console.log("\nDeployment Summary:");
    console.log("-------------------");
    console.log("StakeX Token Address:", await stakeX.getAddress());
    console.log("StakedPool Contract Address:", await stakedPool.getAddress());
  }
);
