// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract VotingEligibility {

    error notEligiableToVote(string message);

    function checkEligibility(uint256 age) public pure returns(bool) {

        if (age < 18) {
            revert notEligiableToVote("You don't have needed age to vote!");
        }
        return (true);
    }
}
