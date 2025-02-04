async function main() {
  const [deployer] = await ethers.getSigners();

  const Token = await ethers.getContractFactory("Token"); // New instance of token contract
  const token = await Token.deploy(); // Deploy new token

  await token.deploymentTransaction().wait();
  console.log("ERC20 token deployed to:", token.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
