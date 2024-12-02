// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Crowdfunding {
    uint256 public goalAmount = 10000;
    uint256 public endTime;

    mapping (address => uint256) public contributions;
    
    constructor(uint256 _durationInDays) {
        endTime = block.timestamp + (_durationInDays * 1);
    }

    function contribute(uint256 baseUnits) external payable {
        require(block.timestamp < endTime, "Campaign has ended.");
        require(msg.value == baseUnits, "Incorrect Ether sent!");
        require(baseUnits > 0, "Contribution must be greater than 0!");

        contributions[msg.sender] += baseUnits;
    }

    function checkGoalReached() external view returns (bool) {
        uint256 totalContributions = getTotalContributions();
        return totalContributions >= goalAmount;
    }

    function getTotalContributions() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() external {
        require(block.timestamp > endTime, "Campaign is still active.");
        require(getTotalContributions() < goalAmount, "Goal was met, cannot withdraw.");

        uint256 contributorAmount = contributions[msg.sender];
        require(contributorAmount > 0, "No contribution to withdraw.");

        contributions[msg.sender] = 0; // Reset contribution before transferring to avoid re-entrancy attack

        payable(msg.sender).transfer(contributorAmount);
    }

}