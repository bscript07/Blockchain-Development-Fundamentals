const { task } = require("hardhat/config");

task("ethTransfer", "Transfer ETH between accounts")
.addParam("recipient", "The address of the recipient")
.addParam("amount", "The amount of ETH to transfer")
.setAction(async({recipient, amount}) => {
    const {ethers} = hre;

    const [sender] = await ethers.getSigners();
    console.log(`Sender address: ${sender.address}`);
    console.log(`Recipient address: ${recipient}`);
    console.log(`Amount to transfer: ${amount} ETH`);
    
    // Convert amount from ETH to Wei
    const amountWei = ethers.utils.parseEther(amount);

    try {
        const tx = await sender.sendTransaction({
            to: recipient,
            value: amountWei
        });

        // Wait for the transaction to be confirmed
        await tx.wait();
        console.log("Transaction confirmed");
    } catch (error) {
        console.log("Transaction failed:", error);
    }
});

module.exports = {};
