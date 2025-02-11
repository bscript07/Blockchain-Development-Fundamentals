// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract BitOrangeToken is ERC20 {
  uint256 public burnPercentage = 1; // 0.01% burn rate

  constructor() ERC20('Crowd', 'CRW') {
    _mint(msg.sender, 50_000 * 10 ** decimals());
  }

  function decimals() public pure override returns (uint8) {
    return 8;
  }

  // Override transfer to implement burn on transfer
  function transfer(
    address recipient,
    uint256 amount
  ) public override returns (bool) {
    uint256 burnAmount = (amount * burnPercentage) / 10000;
    uint256 sendAmount = amount - burnAmount;

    // Burn the tokens
    _burn(_msgSender(), burnAmount);

    // Proceed with transfer
    return super.transfer(recipient, sendAmount);
  }

  // Override transferFrom to implement burn on transferFrom
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public override returns (bool) {
    uint256 burnAmount = (amount * burnPercentage) / 10000;
    uint256 sendAmount = amount - burnAmount;

    // Burn the tokens
    _burn(sender, burnAmount);

    return super.transferFrom(sender, recipient, sendAmount);
  }
}
