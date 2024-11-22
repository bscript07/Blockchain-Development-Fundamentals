// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract LoanInterestCalculator {

    error InvalidInterestRate(string message);
    error InvalidLoanPeriod(string message);

    function CalculateTotalPayable(uint256 principal, uint256 interestRate , uint256 loanPeriod) public pure returns(uint256) {

        if (interestRate > 100) {
            revert("Interest rate must be between 0 and 100%");
        }

        if (loanPeriod < 1) {
            revert("Loan period must be at least 1 year.");
        }

        uint256 interest = (principal * interestRate * loanPeriod) / 100;
        uint256 totalPayable = principal + interest;

        return totalPayable;
    }
} 
