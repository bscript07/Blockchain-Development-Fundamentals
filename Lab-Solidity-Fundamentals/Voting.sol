// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

struct Voter {
    bool hasVoted;
    uint256 choice;
}

contract Voting {
    mapping(address => Voter) public voting;

    function registerVote(uint256 _candidateId) external {
        require(!voting[msg.sender].hasVoted, "You are already voted.");

        voting[msg.sender] = Voter({hasVoted: true, choice: _candidateId});
    }

    function getVoterStatus(address _voter)
        external
        view
        returns (bool, uint256)
    {
        Voter memory voter = voting[_voter];
        return (voter.hasVoted, voter.choice);
    }
}