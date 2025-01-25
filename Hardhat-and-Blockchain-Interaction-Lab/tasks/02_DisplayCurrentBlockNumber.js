task("displayBlock", "Fetches and display the current block number").setAction(
  async (_, hre) => {
    try {
      const blockNumber = await hre.ethers.provider.getBlockNumber();
      console.log(`Current block number: ${blockNumber}`);
    } catch (error) {
      console.log("Error fetching the block number", error);
    }
  }
);

module.exports = {};
