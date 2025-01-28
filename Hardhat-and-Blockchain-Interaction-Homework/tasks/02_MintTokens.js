task("mintTokens", "Mint tokens to a specific address")
  .addParam("recipient", "Address to receive the tokens")
  .addParam("amount", "Amount of tokens to mint")
  .setAction(async ({ recipient, amount }, hre) => {
    const [owner] = await hre.ethers.getSigners();

    // Get the EcoBalance contract
    const EcoBalance = await hre.ethers.getContractFactory("EcoBalance");
    const ecoTokens = await EcoBalance.attach(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
    );

    // Mint tokens
    try {
      const tx = await ecoTokens
        .connect(owner)
        .mint(recipient, hre.ethers.parseEther(amount));

      await tx.wait();
      console.log("Minting successful!");
    } catch (error) {
      console.log("Minting failed:", error);
    }
  });

module.exports = {};
