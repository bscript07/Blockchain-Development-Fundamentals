// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import {IBitOrangeToken} from './IBitOrangeToken.sol';

contract Crowdsale is Ownable {
  uint256 public constant MIN_SALE_PERIOD = 20 days;

  address public token;
  uint256 public price;
  uint256 public startTime;
  uint256 public endTime;
  address public feeReceiver;
  uint256 public tokensForSale;
  uint256 public tokensSold;
  bool public isFinished;

  uint256 public softCap;
  mapping(address => uint256) public contributions;
  bool public softCapReached;

  error InvalidStartTime(string message);
  error InvalidEndTime(string message);
  error InvalidFeeReceiver();
  error OutOfSalePeriod();
  error SaleActive();
  error UnsuccessfullWithdraw();
  error AlreadyFinished();
  error InputValueTooSmall();
  error InsufficientTokens();
  error NotReachedSoftCap();
  error NoContributionToRefund();

  event SaleInitialized(
    uint256 startTime,
    uint256 endTime,
    uint256 price,
    address feeReceiver,
    address token,
    uint256 tokensForSale
  );

  event TokensPurchased(
    address indexed buyer,
    address indexed receiver,
    uint256 etherAmount,
    uint256 tokenAmount
  );

  event SaleFinalized(
    uint256 tokensSold,
    uint256 ethersRaised,
    uint256 remainingTokens
  );

  constructor(address owner) Ownable(owner) {}

  /**
   * Set initial Crowdsale parameters
   * @param _startTime start of the sale
   * @param _endTime end of the sale
   * @param _rateETH how much tokens are sold for 1 ETH
   */

  function initialize(
    uint256 _startTime,
    uint256 _endTime,
    uint256 _rateETH,
    address _feeReceiver,
    address _token,
    uint256 _tokensForSale,
    uint256 _softCap
  ) external onlyOwner {
    if (_softCap == 0) {
      revert NotReachedSoftCap();
    }

    if (_startTime < block.timestamp) {
      revert InvalidStartTime('Start time must be in the future');
    }

    if (_startTime > block.timestamp + 25 days) {
      revert InvalidStartTime(
        'Start time must be in the future within 25 days'
      );
    }

    if (_endTime < _startTime + MIN_SALE_PERIOD) {
      revert InvalidEndTime('End time must be al least MIN_SALE_PERIOD');
    }

    if (_feeReceiver == address(0)) {
      revert InvalidFeeReceiver();
    }

    softCap = _softCap;

    startTime = _startTime;
    endTime = _endTime;
    price = _rateETH;
    feeReceiver = _feeReceiver;
    token = _token;
    tokensForSale = _tokensForSale;

    IBitOrangeToken(token).transferFrom(
      msg.sender,
      address(this),
      tokensForSale
    );

    emit SaleInitialized(
      startTime,
      endTime,
      price,
      feeReceiver,
      token,
      tokensForSale
    );
  }

  function buyShares(address receiver) external payable {
    if (
      block.timestamp < startTime || block.timestamp > endTime || isFinished
    ) {
      revert OutOfSalePeriod();
    }

    uint256 tokensToReceive = (msg.value *
      price *
      (10 ** IBitOrangeToken(token).decimals())) / 1 ether;

    if (tokensToReceive == 0) {
      revert InputValueTooSmall();
    }

    if (tokensSold + tokensToReceive > tokensForSale) {
      revert InsufficientTokens();
    }

    contributions[msg.sender] += msg.value; // current contributor

    tokensSold += tokensToReceive;

    if (address(this).balance >= softCap) {
      softCapReached = true;
    }

    IBitOrangeToken(token).transfer(receiver, tokensToReceive);

    emit TokensPurchased(msg.sender, receiver, msg.value, tokensToReceive);
  }

  function claimRefund() external {
    if (softCapReached) {
      revert NotReachedSoftCap();
    }

    if (block.timestamp < endTime) {
      revert SaleActive();
    }

    uint256 contribution = contributions[msg.sender];
    require(contribution > 0, 'No contribution to refund');

    contributions[msg.sender] = 0;

    (bool success, ) = msg.sender.call{value: contribution}('');
    if (!success) {
      revert UnsuccessfullWithdraw();
    }
  }

  function finalizeSale() external onlyOwner {
    if (isFinished) {
      revert AlreadyFinished();
    }

    if (
      tokensSold < tokensForSale &&
      block.timestamp <= endTime &&
      !softCapReached
    ) {
      revert SaleActive();
    }

    isFinished = true;

    uint256 remainingTokens = IBitOrangeToken(token).balanceOf(address(this));
    uint256 ethersRaised = address(this).balance;

    if (softCapReached) {
      (bool success, ) = feeReceiver.call{value: ethersRaised}('');
      if (!success) {
        revert UnsuccessfullWithdraw();
      }

      IBitOrangeToken(token).transfer(owner(), remainingTokens);
    }
    emit SaleFinalized(tokensSold, ethersRaised, remainingTokens);
  }
}
