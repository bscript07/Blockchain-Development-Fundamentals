async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contract with account: ${deployer.address}`);

  const Counter = await ethers.getContractFactory("Counter");
  const counter = await Counter.deploy();

  await counter.deploymentTransaction().wait();
  console.log("Counter contract deployed at:", counter.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
