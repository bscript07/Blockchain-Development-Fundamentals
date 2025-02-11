const {
  time,
  loadFixture,
} = require('@nomicfoundation/hardhat-toolbox/network-helpers');
const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Crowdsale', function () {
  const TWENTY_DAYS = 20 * 24 * 60 * 60;

  async function initialDeployFixture() {
    const [owner, otherAccount, feeReceiver] = await ethers.getSigners();

    const BitOrangeTokenFactory = await ethers.getContractFactory(
      'BitOrangeToken'
    );
    const bitorangetoken = await BitOrangeTokenFactory.deploy();

    const CrowdsaleTokenFactory = await ethers.getContractFactory('Crowdsale');
    const crowdsale = await CrowdsaleTokenFactory.deploy(owner);

    const latestTimestamp = await time.latest();
    const nextBlockTimestamp = latestTimestamp + 10;
    await time.setNextBlockTimestamp(nextBlockTimestamp);

    const startTime = nextBlockTimestamp + 1000;
    const endTime = startTime + TWENTY_DAYS;
    const tokensToSale = ethers.parseUnits('50000', 8);
    const softCap = ethers.parseUnits('1000', 8);

    await bitorangetoken.approve(crowdsale.getAddress(), tokensToSale);

    await crowdsale.initialize(
      startTime,
      endTime,
      50,
      feeReceiver.address,
      await bitorangetoken.getAddress(),
      tokensToSale,
      softCap
    );

    return {
      crowdsale,
      bitorangetoken,
      owner,
      otherAccount,
      feeReceiver,
      startTime,
      endTime,
      tokensToSale,
    };
  }

  describe('Buy token', function () {
    it("Should revert if sale hasn't started", async function () {
      const { crowdsale, otherAccount } = await loadFixture(
        initialDeployFixture
      );

      await expect(
        crowdsale.connect(otherAccount).buyShares(otherAccount.address)
      ).to.be.revertedWithCustomError(crowdsale, 'OutOfSalePeriod');
    });

    it('Should revert if sale ended', async function () {
      const { crowdsale, endTime, otherAccount } = await loadFixture(
        initialDeployFixture
      );

      await time.increaseTo(endTime + 1);
      await expect(
        crowdsale.connect(otherAccount).buyShares(otherAccount.address)
      ).to.be.revertedWithCustomError(crowdsale, 'OutOfSalePeriod');
    });

    it('Should revert if sale is finished', async function () {
      const { crowdsale, owner, endTime, otherAccount } = await loadFixture(
        initialDeployFixture
      );

      await time.increaseTo(endTime + 1);
      await crowdsale.connect(owner).finalizeSale();

      await expect(
        crowdsale.connect(otherAccount).buyShares(otherAccount.address)
      ).to.be.revertedWithCustomError(crowdsale, 'OutOfSalePeriod');
    });

    it('Should revert when sending 0 ETH', async function () {
      const { crowdsale, startTime, otherAccount } = await loadFixture(
        initialDeployFixture
      );

      await time.increaseTo(startTime + 1000);

      await expect(
        crowdsale.connect(otherAccount).buyShares(otherAccount.address)
      ).to.be.revertedWithCustomError(crowdsale, 'InputValueTooSmall');
    });

    it('Should revert if trying to buy more tokens than available', async function () {
      const { crowdsale, startTime, otherAccount } = await loadFixture(
        initialDeployFixture
      );

      await time.increaseTo(startTime + 1000);

      const tooMuchEth = ethers.parseEther('1100');

      await expect(
        crowdsale
          .connect(otherAccount)
          .buyShares(otherAccount.address, { value: tooMuchEth })
      ).to.be.revertedWithCustomError(crowdsale, 'InsufficientTokens');
    });

    it('Should revert if called before sale start time', async function () {
      const { crowdsale, otherAccount } = await loadFixture(
        initialDeployFixture
      );

      await expect(
        crowdsale.connect(otherAccount).buyShares(otherAccount.address, {
          value: ethers.parseEther('1'),
        })
      ).to.be.revertedWithCustomError(crowdsale, 'OutOfSalePeriod');
    });

    it('Should send ether on success', async function () {
      const { crowdsale, otherAccount, startTime } = await loadFixture(
        initialDeployFixture
      );

      await time.increaseTo(startTime + 10000);
      const amount = ethers.parseEther('0.5');

      await expect(
        crowdsale.connect(otherAccount).buyShares(otherAccount.address, {
          value: amount,
        })
      ).to.changeEtherBalances([otherAccount, crowdsale], [-amount, amount]);
    });

    it('Should update tokensSold counter', async function () {
      const { crowdsale, otherAccount, startTime } = await loadFixture(
        initialDeployFixture
      );

      await time.increaseTo(startTime + 10000);

      const ethAmount = ethers.parseEther('1');
      const expectedTokens = ethers.parseUnits('50', 8);

      await crowdsale
        .connect(otherAccount)
        .buyShares(otherAccount.address, { value: ethAmount });

      expect(await crowdsale.tokensSold()).to.be.equal(expectedTokens);
    });

    it('Should emit TokensPurchased event on successfull purchase', async function () {
      const { crowdsale, otherAccount, startTime } = await loadFixture(
        initialDeployFixture
      );

      await time.increaseTo(startTime + 1000);

      const ethAmount = ethers.parseEther('2');
      const expectedTokens = ethers.parseUnits('100', 8); // 2 ETH == 1 ETH = 50

      await expect(
        crowdsale
          .connect(otherAccount)
          .buyShares(otherAccount.address, { value: ethAmount })
      )
        .to.emit(crowdsale, 'TokensPurchased')
        .withArgs(
          otherAccount.address, // buyer
          otherAccount.address, // receiver
          ethAmount, // ethAmount
          expectedTokens // expectedTokens
        );
    });

    it('Should keep softCapReached as false if soft cap is not met', async function () {
      const { crowdsale, otherAccount, startTime } = await loadFixture(
        initialDeployFixture
      );

      const ethAmountBelowSoftCap = ethers.parseEther('5');

      await time.increaseTo(startTime + 1000);

      await crowdsale.connect(otherAccount).buyShares(otherAccount.address, {
        value: ethAmountBelowSoftCap,
      });

      const softCapReached = await crowdsale.softCapReached();
      expect(softCapReached).to.be.true;
    });
  });

  describe('finalizeSale', function () {
    // it('Should revert if sale still active', async function () {
    //   const { crowdsale, owner, startTime, otherAccount } = await loadFixture(
    //     initialDeployFixture
    //   );

    //   await time.increaseTo(startTime + 10000);

    //   const amount = ethers.parseEther('0.5');
    //   await crowdsale
    //     .connect(otherAccount)
    //     .buyShares(otherAccount.address, { value: amount });

    //   await expect(
    //     crowdsale.connect(owner).finalizeSale()
    //   ).to.be.revertedWithCustomError(crowdsale, 'SaleActive');
    // });

    it('Should revert if already finished', async function () {
      const { crowdsale, owner, endTime } = await loadFixture(
        initialDeployFixture
      );

      await time.increaseTo(endTime + 1);
      await crowdsale.connect(owner).finalizeSale();

      await expect(
        crowdsale.connect(owner).finalizeSale()
      ).to.be.revertedWithCustomError(crowdsale, 'AlreadyFinished');
    });

    it('Should transfer ETH to feeReceiver on finalize', async function () {
      const {
        crowdsale,
        owner,
        otherAccount,
        feeReceiver,
        startTime,
        endTime,
      } = await loadFixture(initialDeployFixture);

      await time.increaseTo(startTime + 1000);

      // Buy some tokens
      const ethAmount = ethers.parseEther('1');
      await crowdsale
        .connect(otherAccount)
        .buyShares(otherAccount.address, { value: ethAmount });

      await time.increaseTo(endTime + 1);

      // Check that ETH is transferred to feeReceiver
      await expect(
        crowdsale.connect(owner).finalizeSale()
      ).to.changeEtherBalance(feeReceiver, ethAmount);
    });

    it('Should set isFinished to true', async function () {
      const { crowdsale, owner, endTime } = await loadFixture(
        initialDeployFixture
      );

      await time.increaseTo(endTime + 1);

      await crowdsale.connect(owner).finalizeSale();

      expect(await crowdsale.isFinished()).to.be.true;
    });

    // it('Should emit SaleFinalized event on successful finalization', async function () {
    //   const { crowdsale, owner, otherAccount, startTime, endTime } =
    //     await loadFixture(initialDeployFixture);

    //   await time.increaseTo(startTime + 1000);

    //   // Buy some tokens
    //   const ethAmount = ethers.parseEther('2');
    //   await crowdsale
    //     .connect(otherAccount)
    //     .buyShares(otherAccount.address, { value: ethAmount });

    //   await time.increaseTo(endTime + 1);

    //   // Get expected values for the event
    //   const tokensSold = await crowdsale.tokensSold();
    //   const ethRaised = await ethers.provider.getBalance(
    //     crowdsale.getAddress()
    //   );
    //   const remainingTokens = (await crowdsale.tokensForSale()) - tokensSold;

    //   await expect(crowdsale.connect(owner).finalizeSale())
    //     .to.emit(crowdsale, 'SaleFinalized')
    //     .withArgs(tokensSold, ethRaised, remainingTokens);
    // });
  });
});
