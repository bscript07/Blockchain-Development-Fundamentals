const hre = require("hre");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log(`Deploying contract with the account: ${deployer.address}`);

  const EcoBalance = await hre.ethers.getContractFactory("EcoBalance");
  const initialSupply = hre.ethers.parseEther("1000000000"); // 1 billion tokens
  const ecoTokens = await EcoBalance.deploy(
    "EcoBalance",
    "ECOB",
    initialSupply
  );

  await ecoTokens.deploymentTransaction().wait();
  console.log(`EcoBalance contract deployed successfully`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
