// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract RewardPoolC {
    using SafeERC20 for IERC20;
    IERC20 public depositToken;

    struct Deposit {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Deposit[]) public userDeposits;

    uint256 constant DAILY_REWARD_RATE = 1; // 1% reward per day

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 totalDeposit, uint256 reward);

    constructor(address _depositToken) {
        depositToken = IERC20(_depositToken);
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");

        depositToken.safeTransferFrom(msg.sender, address(this), amount);
        userDeposits[msg.sender].push(Deposit(amount, block.timestamp));

        emit Deposited(msg.sender, amount);
    }

    function calculateReward(address user) public view returns (uint256) {
        Deposit[] memory deposits = userDeposits[user];
        uint256 totalReward = 0;

        for (uint256 i = 0; i < deposits.length; i++) {
            uint256 timeElapsed = block.timestamp - deposits[i].timestamp;
            uint256 reward = (deposits[i].amount *
                DAILY_REWARD_RATE *
                timeElapsed) / (1 days * 100);
            totalReward += reward;
        }

        return totalReward;
    }

    function withdraw() external {
        Deposit[] storage deposits = userDeposits[msg.sender];
        require(deposits.length > 0, "No deposit found");

        uint256 totalDeposit = 0;
        uint256 totalReward = calculateReward(msg.sender);

        // Calculate total deposit and clear a users deposit
        for (uint256 i = 0; i < deposits.length; i++) {
            totalDeposit += deposits[i].amount;
        }

        delete userDeposits[msg.sender]; // Reset user's deposit
        depositToken.safeTransfer(msg.sender, totalDeposit + totalReward);

        emit Withdrawn(msg.sender, totalDeposit, totalReward);
    }
}
