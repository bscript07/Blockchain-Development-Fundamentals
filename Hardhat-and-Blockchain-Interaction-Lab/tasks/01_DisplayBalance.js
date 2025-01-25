task(
  "displayBalance",
  "Display the ethers balance of the first account"
).setAction(async (_, hre) => {
  try {
    const [firstAccount] = await hre.ethers.getSigners();
    const balance = await hre.ethers.provider.getBalance(firstAccount.address);

    const formattedBalance = hre.ethers.formatEther(balance);
    console.log(`Balance task loaded successfully ${formattedBalance}`);
  } catch (error) {
    console.log("Error fetching the block number", error);
  }
});

module.exports = {};

