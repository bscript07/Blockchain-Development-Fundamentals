// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract PayrollCalculator {

    error InvalidSalary(string message);
    error InvalidRating(string message);

    function CalculatePaycheck(uint256 salary, uint256 rating) public pure returns(uint256) {

        if (salary <= 0) {
            revert InvalidSalary("Salary must be greather than zero.");
        }

        if (rating < 0 || rating > 10) {
            revert InvalidRating("Rating must be between 0 and 10.");
        }

        if (rating > 8) {
            salary = salary + (salary * 10) / 100;
        }

        return salary;
    }
}