async function main() {
  const [deployer] = await ethers.getSigners();

  const depositTokenAddress = "0xd6f2E74021e7447D70e85734CA2B808d8d9C2027";
  const RewardPool = await ethers.getContractFactory("RewardPoolC");
  const rewardpool = await RewardPool.deploy(depositTokenAddress);

  await rewardpool.deploymentTransaction().wait();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
