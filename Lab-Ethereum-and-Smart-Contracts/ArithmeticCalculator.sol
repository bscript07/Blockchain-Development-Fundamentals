// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ArithmeticCalculator {

    error DivisionByZero(string message);

    function add(int256 num1, int256 num2) public pure returns (int256) {
        return num1 + num2;
    }

    function subtract(int256 num1, int256 num2) public pure returns (int256) {
        return num1 - num2;
    }

    function multiply(int256 num1, int256 num2) public pure returns (int256) {
        return num1 * num2;
    }

    function divide(int256 num1, int256 num2) public pure returns (int256) {
        // Check for division by zero
        if (num2 == 0) {
            revert DivisionByZero("Cannot divide by zero");
        }
        return num1 / num2;
    }
}
