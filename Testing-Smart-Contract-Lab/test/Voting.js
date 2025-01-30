const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");
const { network } = require("hardhat");

describe("VotingSystem", function () {
  async function deployVotingFixture() {
    const [deployer] = await ethers.getSigners();
    const VotingSystem = await ethers.getContractFactory("VotingSystem");
    const VotingContract = await VotingSystem.deploy();

    return { VotingContract, deployer };
  }

  describe("Deployment VotingContract", function () {
    it("Should set the right owner", async function () {
      const { VotingContract, deployer } = await loadFixture(
        deployVotingFixture
      );

      expect(await VotingContract.owner()).to.be.equal(deployer.address);
    });

    it("Should set proposal count to 0", async function () {
      const { VotingContract } = await loadFixture(deployVotingFixture);

      expect(await VotingContract.proposalCount()).to.be.equal(0);
    });
  });

  describe("createProposal()", async function () {
    it("Should revert when caller is not owner", async function () {
      const { VotingContract, deployer } = await loadFixture(
        deployVotingFixture
      );

      const [_, nonOwner] = await ethers.getSigners();
      await expect(
        VotingContract.connect(nonOwner).createProposal("Proposal 1", 60)
      ).to.be.revertedWithCustomError(VotingContract, "NotOwner");
    });

    it("Should create a proposal successfully", async function () {
      const { VotingContract, deployer } = await loadFixture(
        deployVotingFixture
      );

      const tx = await VotingContract.createProposal("Proposal 1", 60);

      // Retrieve the block timestamp when the transaction was mined
      const blockTimestamp = (await ethers.provider.getBlock(tx.blockNumber))
        .timestamp;
      const expectedVotingEnd = blockTimestamp + 60;

      // Expect the ProposalCreated event with a timestamp close to the expected end time
      await expect(tx).to.emit(VotingContract, "ProposalCreated").withArgs(
        0, // Proposal ID (use the correct ID based on your proposalCount logic)
        "Proposal 1", // description
        expectedVotingEnd // The expected end time
      );

      // Optionally, verify other contract state variables, if necessary
      const proposal = await VotingContract.proposals(0);
      expect(proposal.endTime).to.be.closeTo(expectedVotingEnd, 1); // Allow a 1-second tolerance
    });

    it("Should revert for invalid voting period", async function () {
      const { VotingContract } = await loadFixture(deployVotingFixture);

      await expect(
        VotingContract.createProposal("Invalid proposal", 0)
      ).to.be.revertedWithCustomError(VotingContract, "InvalidVotingPeriod");
    });
  });

  describe("vote()", async function () {
    it("Should cast vote successfully", async function () {
      const { VotingContract, deployer } = await loadFixture(
        deployVotingFixture
      );

      await VotingContract.createProposal("Proposal 1", 60);

      const proposalId = 0;
      await expect(VotingContract.vote(proposalId))
        .to.emit(VotingContract, "VoteCast")
        .withArgs(proposalId, deployer.address);

      const proposal = await VotingContract.proposals(0);
      expect(proposal.voteCount).to.equal(1);
    });

    it("Should revert when voting twice on the same proposal", async function () {
      const { VotingContract } = await loadFixture(deployVotingFixture);

      await VotingContract.createProposal("Proposal 1", 60);
      await VotingContract.vote(0);

      await expect(VotingContract.vote(0)).to.be.revertedWithCustomError(
        VotingContract,
        "AlreadyVoted"
      );
    });

    it("Should revert when voting after the end time", async function () {
      const { VotingContract, deployer } = await loadFixture(
        deployVotingFixture
      );

      await VotingContract.createProposal("Proposal 1", 60);
      const proposalId = 0;
      await VotingContract.vote(proposalId);

      // Advance time 2 seconds
      await ethers.provider.send("evm_increaseTime", [61]);
      await ethers.provider.send("evm_mine");

      await expect(
        VotingContract.vote(proposalId)
      ).to.be.revertedWithCustomError(VotingContract, "VotingEnded");
    });
  });

  describe("executeProposal()", async function () {
    it("Should execute a proposal successfully", async function () {
      const { VotingContract, deployer } = await loadFixture(
        deployVotingFixture
      );

      // Create a proposal with a short voting duration
      await VotingContract.createProposal("Proposal 1", 60);

      // Advance time beyond the voting period
      await ethers.provider.send("evm_increaseTime", [61]);
      await ethers.provider.send("evm_mine");

      // Execute the proposal
      const tx = await VotingContract.executeProposal(0);
      await expect(tx)
        .to.emit(VotingContract, "ProposalExecuted")
        .withArgs(0, 0); // proposalId and voteCount

      const proposal = await VotingContract.proposals(0);
      expect(proposal.executed).to.equal(true);
    });

    it("Should revert if proposal has already been executed", async function () {
      const { VotingContract, deployer } = await loadFixture(
        deployVotingFixture
      );

      // Create a proposal with a short voting duration
      await VotingContract.createProposal("Proposal 1", 60);

      // Advance time beyond the voting period
      await ethers.provider.send("evm_increaseTime", [61]);
      await ethers.provider.send("evm_mine");

      // Execute the proposal
      await VotingContract.executeProposal(0);

      // Try to execute the already executed proposal
      await expect(
        VotingContract.executeProposal(0)
      ).to.be.revertedWithCustomError(
        VotingContract,
        "ProposalAlreadyExecuted"
      );
    });
  });
});
