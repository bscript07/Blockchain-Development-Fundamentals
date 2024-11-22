// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract LoanInterestCalculator {

    error InvalidInterestRate(string message);
    error InvalidLoanPeriod(string message);

    function CalculateTotalPayable(int256 principal, int256 interestRate , int256 loanPeriod) public pure returns(int256) {

        if (interestRate > 100) {
            revert("Interest rate must be between 0 and 100%");
        }

        if (loanPeriod < 1) {
            revert("Loan period must be at least 1 year.");
        }

        int256 interest = (principal * interestRate * loanPeriod) / 100;
        int256 totalPayable = principal + interest;

        return totalPayable;
    }
} 