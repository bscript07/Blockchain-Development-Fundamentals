// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Staking is ReentrancyGuard {
    mapping(address => uint256) public stakes;
    mapping(address => uint256) public lastStakeTimestamp;
    mapping(address => uint256) public rewards;

    uint256 public constant MINIMUM_STAKE = 100;
    uint256 public constant LOCK_PERIOD = 5 seconds;
    uint256 public constant REWARD_RATE = 10; // 10% APR

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);

    function stake() public payable nonReentrant {
        require(msg.value >= MINIMUM_STAKE, "Stake too small");

        // Calculate pending rewards before updating stake
        uint256 pendingReward = calculateReward(msg.sender);
        rewards[msg.sender] += pendingReward;
        stakes[msg.sender] += msg.value;
        lastStakeTimestamp[msg.sender] = block.timestamp;

        emit Staked(msg.sender, msg.value);
    }

    function withdraw() public nonReentrant {
        require(stakes[msg.sender] > 0, "No stake found");
        require(
            block.timestamp >= lastStakeTimestamp[msg.sender] + LOCK_PERIOD,
            "Lock period not over"
        );

        uint256 amount = stakes[msg.sender];
        uint256 reward = calculateReward(msg.sender);
        stakes[msg.sender] = 0;
        rewards[msg.sender] = 0;

        // Transfers should be last
        payable(msg.sender).transfer(amount);
        payable(msg.sender).transfer(reward);

        emit Withdrawn(msg.sender, amount);
        emit RewardClaimed(msg.sender, reward);
    }

    function calculateReward(address user) public view returns (uint256) {
        if (stakes[user] == 0) return 0;

        uint256 duration = block.timestamp - lastStakeTimestamp[user];
        return (stakes[user] * REWARD_RATE * duration) / (365 days * 100);
    }
}
