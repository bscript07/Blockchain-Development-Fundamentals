// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract BillSplitting  {

    function splitExpense(uint256 totalAmount, uint256 numPeople) public pure returns(uint256) {
        return (totalAmount / numPeople);
    }
}