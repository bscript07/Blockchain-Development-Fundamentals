const { task } = require("hardhat/config");

task("ERC20", "Retrieve and display ERC20 token")
.setAction(async(_, hre) => {
    const {ethers} = hre;

    const [owner, player1, player2] = await ethers.getSigners();

    const ERC20 = await ethers.getContractFactory("Dogecoin");
    const token = await ERC20.deploy("Dogecoin", "DC", ethers.utils.parseUnits("1000000", 18)); // Create initial supply 

    await token.deployed();
    console.log("Token deployed to:", token.address);

    const balancePlayer1Initial = await token.balanceOf(player1.address);
    const balancePlayer2Initial = await token.balanceOf(player2.address);
    console.log(`Player 1 initial balance: ${balancePlayer1Initial.toString()}`);
    console.log(`Player 2 initial balance: ${balancePlayer2Initial.toString()}`);

    // Mint 1000 tokens to each player
    const mintAmount = ethers.utils.parseUnits("1000", 18);

    await token.mint(player1.address, mintAmount);
    await token.mint(player2.address, mintAmount);

    // Updated balance
    const balancePlayer1 = await token.balanceOf(player1.address);
    const balancePlayer2 = await token.balanceOf(player2.address);
    console.log(`Player 1 balance: ${balancePlayer1.toString()}`);
    console.log(`Player 2 balance: ${balancePlayer2.toString()}`);

});

module.exports = {};
