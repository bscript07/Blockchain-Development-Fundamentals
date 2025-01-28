task("transferTokens", "Transfer tokens between addresses")
  .addParam("recipient", "Address of the recipient")
  .addParam("amount", "Amount to transfer")
  .setAction(async ({ recipient, amount }, hre) => {
    const [sender] = await hre.ethers.getSigners();
    console.log(`Sender address: ${sender.address}`);
    console.log(`Recipient address: ${recipient}`);
    console.log(`Amount: ${amount}`);

    const amountInWei = await hre.ethers.parseEther(amount);
    console.log(`Amount in Wei: ${amountInWei}`);

    try {
      const tx = await sender.sendTransaction({
        to: recipient,
        value: amountInWei,
      });

      if (sender.address == recipient) {
        throw new Error("Sender and recipient addresses are the same");
      }

      await tx.wait();
      console.log("Transaction successful!");
    } catch (error) {
      console.log("Transaction failed", error);
    }
  });

module.exports = {};
