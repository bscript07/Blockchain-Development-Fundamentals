task("ethTransfer", "Transfer ETH between accounts")
  .addParam("recipient", "The address of the recipient")
  .addParam("amount", "The amount of ETH to transfer")
  .setAction(async ({ recipient, amount }, hre) => {
    const [sender] = await hre.ethers.getSigners();
    console.log(`Sender address: ${sender.address}`);
    console.log(`Recipient address: ${recipient}`);
    console.log(`Amount to transfer: ${amount} ETH`);

    // Convert amount from ETH to Wei
    const amountWei = await hre.ethers.parseEther(amount);
    console.log(`Amount in Wei: ${amountWei.toString()}`);

    try {
      const tx = await sender.sendTransaction({
        to: recipient,
        value: amountWei,
      });

      if (sender.address == recipient) {
        throw new Error("Sender and recipient addresses are the same");
      }

      // Wait for the transaction to be confirmed
      await tx.wait();
      console.log("Transaction confirmed");
    } catch (error) {
      console.log("Transaction failed:", error);
    }
  });

module.exports = {};
