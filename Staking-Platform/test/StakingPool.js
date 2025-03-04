const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("StakingPool", function () {
  async function initialDeployFixture() {
    const [owner, user1, user2] = await ethers.getSigners();

    // Deploy StakeX Token contract
    const StakeX = await ethers.getContractFactory("StakeX");
    const stakeXToken = await StakeX.deploy();
    console.log("StakeX Token deployed at:", await stakeXToken.getAddress());

    // Deploy StakingPool contract
    const StakingPool = await ethers.getContractFactory("StakingPool");
    const stakingPool = await StakingPool.deploy(
      await stakeXToken.getAddress()
    );
    console.log("StakingPool deployed at:", await stakingPool.getAddress());

    // Approve tokens
    await stakeXToken
      .connect(owner)
      .approve(await stakingPool.getAddress(), ethers.parseEther("100000")); // approve 100000 tokens for spender
    console.log("Tokens approved for StakingPool");

    // Mint some StakeX tokens to users
    await stakeXToken.mint(user1.address, ethers.parseUnits("10000", 8));
    console.log(user1.address);

    await stakeXToken.mint(user2.address, ethers.parseUnits("10000", 8));
    console.log(user2.address);

    return { stakeXToken, stakingPool, owner, user1, user2 };
  }

  describe("Deposit", function () {
    it("Should revert if deposit amount is insufficient", async function () {
      const { stakeXToken, stakingPool, user1 } = await loadFixture(
        initialDeployFixture
      );

      const amount = ethers.parseUnits("0", 8);
      await stakeXToken
        .connect(user1)
        .approve(await stakingPool.getAddress(), amount);

      await expect(
        stakingPool.connect(user1).deposit(amount)
      ).to.be.revertedWithCustomError(stakingPool, "InsufficientAmount");
    });

    it("Should allow users to deposit tokens", async function () {
      const { stakeXToken, stakingPool, user1 } = await loadFixture(
        initialDeployFixture
      );

      const amount = ethers.parseUnits("100", 8);

      // Check if approval works
      const approveTx = await stakeXToken
        .connect(user1)
        .approve(await stakingPool.getAddress(), amount);
      await approveTx.wait();

      // Deposit
      await stakingPool.connect(user1).deposit(amount);

      expect(await stakingPool.totalStaked()).to.equal(amount);
    });
  });

  describe("Minting and Claiming Rewards", function () {
    it("Should mint the correct amount of rewards", async function () {
      const { stakeXToken, user1 } = await loadFixture(initialDeployFixture);

      // Set the reward amount and the address to mint to
      const rewardAmount = ethers.parseUnits("10000", 8);

      // Check the balance before minting
      const finalBalance = await stakeXToken.balanceOf(user1.address);

      // Assert that the final balance equals the reward amount
      expect(finalBalance).to.equal(rewardAmount);
    });

    it("Should revert if there are no available rewards", async function () {
      const { stakingPool, user1 } = await loadFixture(initialDeployFixture);

      await expect(
        stakingPool.connect(user1).claimRewards()
      ).to.be.revertedWithCustomError(stakingPool, "NoAvailableRewards");
    });
  });

  describe("Withdraw", function () {
    it("Should revert if user has insufficient balance for withdraw", async function () {
      const { stakeXToken, stakingPool, user1 } = await loadFixture(
        initialDeployFixture
      );

      const amount = ethers.parseUnits("100", 8);
      await stakeXToken
        .connect(user1)
        .approve(await stakingPool.getAddress(), amount);

      // Deposit amount
      await stakingPool.connect(user1).deposit(amount);

      // Withdraw amount
      const withdrawAmount = ethers.parseUnits("200", 8);

      await expect(
        stakingPool.connect(user1).withdraw(withdrawAmount)
      ).to.be.revertedWithCustomError(stakingPool, "InsufficientBalance");
    });

    it("Should revert if withdraw amount is zero", async function () {
      const { stakeXToken, stakingPool, user1 } = await loadFixture(
        initialDeployFixture
      );

      const amount = ethers.parseUnits("0", 8);
      await stakeXToken
        .connect(user1)
        .approve(await stakingPool.getAddress(), amount);

      await expect(
        stakingPool.connect(user1).withdraw(amount)
      ).to.be.revertedWithCustomError(stakingPool, "InsufficientAmount");
    });

    it("Should allow users to withdraw tokens", async function () {
      const { stakeXToken, stakingPool, user1 } = await loadFixture(
        initialDeployFixture
      );

      // Deposit 1000 tokens
      const amount = ethers.parseUnits("1000", 8);

      // Tokens approve
      const approveTx = await stakeXToken
        .connect(user1)
        .approve(await stakingPool.getAddress(), amount);

      await approveTx.wait();

      // Deposit tokens to staking pool
      await stakingPool.connect(user1).deposit(amount);

      // Balance tokens before withdraw
      const stakerBefore = await stakingPool.stakers(user1.address);
      console.log(
        "User balance before withdrawal: ",
        stakerBefore.balance.toString()
      );

      // Withdraw
      await stakingPool.connect(user1).withdraw(amount);

      // Balance tokens after withdraw
      const stakerAfter = await stakingPool.stakers(user1.address);
      console.log(
        "User balance after withdrawal: ",
        stakerAfter.balance.toString()
      );

      // Condition for zero balance tokens after withdraw
      expect(stakerAfter.balance).to.equal(0);

      // Condition if totalStaked balance is 0
      expect(await stakingPool.totalStaked()).to.equal(0);
    });
  });
});
