const { task } = require('hardhat/config');

task('deploy', 'Deploys BitOrangeToken and Crowdsale contracts')
  .addParam('startoffset', 'Sale start time offset in seconds from now', '1000')
  .addParam(
    'duration',
    'Sale duration in seconds',
    (20 * 24 * 60 * 60).toString()
  )
  .addParam('price', 'Tokens price (tokens per ETH)', '50')
  .addParam('tokensforsale', 'Amount of tokens for sale', '50000')
  .addParam('feereceiver', 'Address that receives the fees', '')
  .setAction(async (taskArgs, hre) => {
    const [deployer] = await hre.ethers.getSigners();
    console.log('Deploying contracts with account:', deployer.address);

    const startoffset = parseInt(taskArgs.startoffset);
    const duration = parseInt(taskArgs.duration);
    const price = parseInt(taskArgs.price);
    const tokensforsale = hre.ethers.parseUnits(taskArgs.tokensforsale, 8);
    const feereceiver = taskArgs.feereceiver || deployer.address;

    // bitorangetoken
    const BitOrangeToken = await hre.ethers.getContractFactory(
      'BitOrangeToken'
    );
    const bitorangetoken = await BitOrangeToken.deploy();
    await bitorangetoken.waitForDeployment();
    console.log(
      'BitOrangeToken deployed to:',
      await bitorangetoken.getAddress()
    );

    // Crowdsale
    const Crowdsale = await hre.ethers.getContractFactory('Crowdsale');
    const crowdsale = await Crowdsale.deploy(deployer.address);

    await crowdsale.waitForDeployment();
    console.log('Crowdsale deployed to:', await crowdsale.getAddress());

    // Calculate timestamps
    const latestBlock = await hre.ethers.provider.getBlock('latest');
    const startTime = latestBlock.timestamp + startoffset;
    const endTime = startTime + duration;

    // Approve BitOrangeToken for Crowdsale
    await bitorangetoken.approve(crowdsale.address, tokensforsale);
    console.log('bitorangetoken approved for sale');

    // Initialize Crowdsale
    await crowdsale.initialize(
      startTime,
      endTime,
      price,
      feereceiver,
      await bitorangetoken.getAddress(),
      tokensforsale
    );
    console.log('Crowdsale initialized');

    // Verify contracts if on Sepolia
    if (hre.network.name === 'sepolia') {
      console.log('\nVerifying contracts on Sepolia...');

      console.log('Waiting for block confirmations...');
      await bitorangetoken.deploymentTransaction().wait();
      await crowdsale.deploymentTransaction().wait();

      // Verify BitOrangeToken
      try {
        await hre.run('verify:verify', {
          address: await bitorangetoken.getAddress(),
          constructorArguments: [],
        });
        console.log('bitorangetoken verified successfully');
      } catch (error) {
        console.log('bitorangetoken verification failed:', error.message);
      }

      try {
        await hre.run('verify:verify', {
          address: await crowdsale.getAddress(),
          constructorArguments: [deployer.address],
        });
        console.log('Crowdsale verified successfully');
      } catch (error) {
        console.log('Crowdsale verification failed:', error.message);
      }
    }

    console.log('\nDeployment Summary:');
    console.log('-------------------');
    console.log('bitorangetoken:', await bitorangetoken.getAddress());
    console.log('Crowdsale:', await crowdsale.getAddress());
    console.log('Start Time:', new Date(startTime * 1000).toLocaleString());
    console.log('End Time:', new Date(endTime * 1000).toLocaleString());
    console.log('Price:', price, 'tokens per ETH');
    console.log('Tokens for Sale:', hre.ethers.formatUnits(tokensforsale, 8));
    console.log('Fee Receiver:', feereceiver);
  });

task('buy', 'Buy tokens from the Crowdsale contract')
  .addParam('crowdsale', 'Address of the Crowdsale contract')
  .addParam('amount', 'Amount of ETH to spend')
  .addOptionalParam('receiver', 'Address to receive tokens', '')
  .setAction(async (taskArgs, hre) => {
    const [buyer] = await hre.ethers.getSigners();
    console.log('Buying tokens with account:', buyer.address);

    // Parse parameters
    const crowdsaleAddress = taskArgs.crowdsale;
    const ethAmount = hre.ethers.parseEther(taskArgs.amount);
    const receiver = taskArgs.receiver || buyer.address;

    // Get contract instance
    const Crowdsale = await hre.ethers.getContractFactory('Crowdsale');
    const crowdsale = Crowdsale.attach(crowdsaleAddress);

    // Get token address and create token instance for balance checking
    const tokenAddress = await crowdsale.token();
    const bitorangetoken = await hre.ethers.getContractFactory(
      'BitOrangeToken'
    );
    const token = bitorangetoken.attach(tokenAddress);

    const initialTokenBalance = await token.balanceOf(receiver);
    const initialEthBalance = await hre.ethers.provider.getBalance(receiver);

    console.log('\nTransaction Details:');
    console.log('-------------------');
    console.log('Crowdsale Address:', crowdsaleAddress);
    console.log('Token Address:', tokenAddress);
    console.log('ETH Amount:', hre.ethers.formatEther(ethAmount), 'ETH');
    console.log('Receiver:', receiver);
    console.log(
      'Initial Token Balance:',
      hre.ethers.formatUnits(initialTokenBalance, 8)
    );

    // Execute purchase
    console.log('\nExecuting purchase...');
    const tx = await crowdsale.buyShares(receiver, { value: ethAmount });
    await tx.wait();

    // Get final balances
    const finalTokenBalance = await token.balanceOf(receiver);
    const finalEthBalance = await hre.ethers.provider.getBalance(receiver);

    // Calculate changes
    const tokenChange = finalTokenBalance - initialTokenVBalance;
    const ethChange = finalEthBalance - initialEthBalance;

    console.log('\nPurchase Summary:');
    console.log('----------------');
    console.log('Tokens Received:', hre.ethers.formatUnits(tokenChange, 8));
    console.log('ETH Spent:', hre.ethers.formatEther(ethChange * -1n), 'ETH');
    console.log(
      'New Token Balance:',
      hre.ethers.formatUnits(finalTokenBalance, 8)
    );

    // Get sale status
    const tokensSold = await crowdsale.tokensSold();
    const tokensForSale = await crowdsale.tokensForSale();

    console.log('\nSale Status:');
    console.log('------------');
    console.log('Tokens Sold:', hre.ethers.formatUnits(tokensSold, 8));
    console.log(
      'Tokens Remaining:',
      hre.ethers.formatUnits(tokensForSale - tokensSold, 8)
    );
    console.log(
      'Sale Progress:',
      ((Number(tokensSold) * 100) / Number(tokensForSale)).toFixed(2),
      '%'
    );
  });
