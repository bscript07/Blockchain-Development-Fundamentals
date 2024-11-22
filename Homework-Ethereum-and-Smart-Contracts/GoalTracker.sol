// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract GoalTracker {
    uint256 public goalAmount;
    uint256 public baseRewardAmount;
    uint256 public spendingTotal;
    uint256 public totalReward;
    bool public claimedRewards;

    event SpendingAdded(uint256 amount, uint256 total);
    event RewardClaimed(uint256 reward);

    error GoalNotMet();
    error AlreadyClaimed();

    constructor(uint256 _goalAmount, uint256 _baseRewardAmount) {
        goalAmount = _goalAmount;
        baseRewardAmount = _baseRewardAmount;
        spendingTotal = 0;
        totalReward = 0;
        claimedRewards = false;
    }

    function addSpending(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        spendingTotal += amount;
        emit SpendingAdded(amount, spendingTotal);
    }

    function claimReward() external {
        if (claimedRewards) revert AlreadyClaimed();
        if (spendingTotal < goalAmount) revert GoalNotMet();

        claimedRewards = true;

        for (uint256 i = 0; i < 5; i++) {
            totalReward += baseRewardAmount;
        }

        emit RewardClaimed(totalReward);
    }
}