// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract CompoundInterestCalculator {

    function calculateCompoundInterest(
     uint256 principal,
     uint256 rate, 
     uint256 ys) public pure returns(uint256) {
        require(principal > 0, "Principal must be greater than zero.");
        require(rate > 0, "Rate must be greater than zero.");
        require(ys > 0, "Years must be greater than zero.");

        uint256 balance = principal;

        for (uint256 i = 0; i < ys; i++) {
            balance += (balance * rate) / 100;
        }

        return balance;
     }
}