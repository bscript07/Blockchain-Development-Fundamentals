task(
  "contractsEventListener",
  "Deploy ERC20 contract and listen for Transfer events"
).setAction(async (_, hre) => {
  const [deployer] = await hre.ethers.getSigners();

  // Deploy the Dogecoin contract
  const Dogecoin = await hre.ethers.getContractFactory("Dogecoin");
  const initialSupply = hre.ethers.parseUnits("1000000", 18); // 1 million tokens with 18 decimals
  const token = await Dogecoin.deploy("Dogecoin", "DC", initialSupply);

  // Get the deployed contract instance
  try {
    const tokenContract = await hre.ethers.getContractAt(
      "Dogecoin",
      token.address
    );

    // Listen for Transfer events
    tokenContract.on("Transfer", (from, to, value, event) => {
      console.log(`
          Transfer Event Detected:
          - From: ${from}
          - To: ${to}
          - Value: ${hre.ethers.formatUnits(value, 18)} DC
          - Event Details: ${JSON.stringify(event, null, 2)}
        `);
    });

    // Prevent process exit
    process.stdin.resume();
  } catch (error) {
    console.error("Error getting contract instance:", error);
    process.exit(1);
  }
});

module.exports = {};
