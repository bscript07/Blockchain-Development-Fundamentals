task("deployContract", "Deploy EcoBalance contract").setAction(
  async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();
    console.log(`Deploying contract with the account: ${deployer.address}`);

    const EcoBalance = await hre.ethers.getContractFactory("EcoBalance");
    const initialSupply = hre.ethers.parseEther("1000000000000000000"); // 1e18 => ``1 ECOB = 1000000000000000000 eco satoshies``
    const ecoTokens = await EcoBalance.deploy(
      "EcoBalance",
      "ECOB",
      initialSupply
    );

    await ecoTokens.deploymentTransaction().wait();
    console.log(`EcoBalance contract deployed successfully`);
  }
);

module.exports = {};
