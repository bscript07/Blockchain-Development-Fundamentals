task(
  "retrieveAndPrintAddresses",
  "Retrieve and print addresses of all accounts"
).setAction(async (_, hre) => {
  try {
    const accounts = await hre.ethers.getSigners();
    let counter = 0;

    accounts.forEach((account) => {
      console.log(`Account address: ${account.address}`);
      console.log(counter++);
    });
  } catch (error) {
    console.log("Error retrieving accounts:", error);
  }
});

module.exports = {};

