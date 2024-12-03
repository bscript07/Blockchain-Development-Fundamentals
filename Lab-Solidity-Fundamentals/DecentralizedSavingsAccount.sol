// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

struct SavingsAccount {
    address owner;
    uint256 balance;
    uint256 creationTime;
    uint256 lockPeriod;
}

contract DecentralizedSavingsAccount {

    mapping (address => SavingsAccount[]) public savingsPlans;

    function createSavingsPlan(uint256 _lockPeriod) external payable {

        require(_lockPeriod > 0, "Lock period must be greater than zero.");

        savingsPlans[msg.sender].push(SavingsAccount({
            owner: msg.sender,
            balance: msg.value,
            creationTime: block.timestamp,
            lockPeriod: _lockPeriod
        }));

    }

    function viewSavingsPlan(uint256 plan) external view returns (SavingsAccount memory) {
        require(plan < savingsPlans[msg.sender].length, "No plan!");
        return savingsPlans[msg.sender][plan];
    }

    function withdrawFunds(uint256 plan) external {
        require(plan < savingsPlans[msg.sender].length, "No plan!");

        SavingsAccount storage account = savingsPlans[msg.sender][plan];

        require(account.owner == msg.sender, "Not the owner on this plan!");
        require(account.balance > 0, "No funds available for withdrawal.");
        require(block.timestamp >= account.creationTime + account.lockPeriod, "Lock period has not expired.");

        uint256 amount = account.balance;
        account.balance = 0; // Reset for prevent re-entrancy attack

        payable(msg.sender).transfer(amount);

    }
}