const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Crowdsale", function () {
  const ONE_WEEK = 7 * 24 * 60 * 60;
  const TOKEN_ID = 0;

  async function initialDeployFixture() {
    // Contracts are deployed using the first signer/account by default
    const [seller, bidder, bidderTwo] = await ethers.getSigners();

    const CustomTokenFactory = await ethers.getContractFactory("NFT");
    const nftContract = await CustomTokenFactory.deploy(seller.address);

    const AuctionHouseFactory = await ethers.getContractFactory("AuctionHouse");
    const auctionContract = await AuctionHouseFactory.deploy();

    return {
      nftContract,
      auctionContract,
      seller,
      bidder,
    };
  }

  describe("Create Auction", function () {
    it("Should revert if min price < 0", async function () {
      const { auctionContract, seller, nftContract } = await loadFixture(
        initialDeployFixture
      );

      await expect(
        auctionContract
          .connect(seller)
          .createAuction(
            TOKEN_ID,
            await nftContract.getAddress(),
            0,
            0,
            0,
            0,
            0,
            0
          )
      ).to.be.revertedWithCustomError(auctionContract, "CannotBeZero");
    });

    it("Should revert if start time < block.timestamp", async function () {
      const { auctionContract, seller, nftContract } = await loadFixture(
        initialDeployFixture
      );

      const latest = await time.latest();
      const next = latest + 2;
      time.setNextBlockTimestamp(next);

      await expect(
        auctionContract
          .connect(seller)
          .createAuction(
            TOKEN_ID,
            await nftContract.getAddress(),
            1,
            next - 1,
            0,
            0,
            0,
            0
          )
      ).to.be.revertedWithCustomError(auctionContract, "InvalidStartTime");
    });

    it("Should revert if end time too low", async function () {
      const { auctionContract, seller, nftContract } = await loadFixture(
        initialDeployFixture
      );

      const latest = await time.latest();
      const next = latest + 2;
      time.setNextBlockTimestamp(next);
      const ONE_DAY = 24 * 60 * 60;

      await expect(
        auctionContract
          .connect(seller)
          .createAuction(
            TOKEN_ID,
            await nftContract.getAddress(),
            1,
            next,
            next + ONE_DAY - 1,
            0,
            0,
            0
          )
      )
        .to.be.revertedWithCustomError(auctionContract, "InvalidEndTime")
        .withArgs("Too low");
    });

    it("Should revert if end time too high", async function () {
      const { auctionContract, seller, nftContract } = await loadFixture(
        initialDeployFixture
      );

      const latest = await time.latest();
      const next = latest + 2;
      time.setNextBlockTimestamp(next);
      const SIXTY_DAYS = 24 * 60 * 60 * 60;

      await expect(
        auctionContract
          .connect(seller)
          .createAuction(
            TOKEN_ID,
            await nftContract.getAddress(),
            1,
            next,
            next + SIXTY_DAYS + 1,
            0,
            0,
            0
          )
      )
        .to.be.revertedWithCustomError(auctionContract, "InvalidEndTime")
        .withArgs("Too high");
    });

    it("Should properly transfer NFT", async function () {
      const { auctionContract, seller, nftContract } = await loadFixture(
        initialDeployFixture
      );

      const nftContractAddress = await nftContract.getAddress();
      const auctionContractAddress = await auctionContract.getAddress();

      await nftContract
        .connect(seller)
        .approve(auctionContractAddress, TOKEN_ID);

      expect(await nftContract.ownerOf(TOKEN_ID)).to.equal(seller.address);

      const latest = await time.latest();
      const next = latest + 2;
      const SIXTY_DAYS = 24 * 60 * 60 * 60;
      time.setNextBlockTimestamp(next);

      await auctionContract
        .connect(seller)
        .createAuction(
          TOKEN_ID,
          nftContractAddress,
          1,
          next,
          next + SIXTY_DAYS,
          1,
          1,
          1
        );
      expect(await nftContract.ownerOf(TOKEN_ID)).to.equal(
        auctionContractAddress
      );
      const auction = await auctionContract.auctions(0);

      expect(auction.seller).to.equal(seller.address);
      expect(auction.tokenId).to.equal(TOKEN_ID);
      expect(auction.nftAddress).to.equal(nftContractAddress);
      expect(auction.minPrice).to.equal(1);
      expect(auction.startTime).to.equal(next);
      expect(auction.endTime).to.equal(next + SIXTY_DAYS);
      expect(auction.bidIncrement).to.equal(1);
      expect(auction.timeExtensionWindow).to.equal(1);
      expect(auction.timeExtensionIncrease).to.equal(1);
      expect(auction.seller).to.equal(seller.address);

      expect(auction.nftClaimed).to.equal(false);
      expect(auction.rewardClaimed).to.equal(false);
    });
  });
});
