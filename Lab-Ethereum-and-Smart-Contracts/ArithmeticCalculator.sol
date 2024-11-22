// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ArithmeticCalculator {

    function add(int256 num1, int256 num2) public pure returns(int256) {
        return (num1 + num2);
    }

    function subtract(int256 num1, int256 num2) public pure returns(int256) {
        return (num1 - num2);
    }

    function multiply(int256 num1, int256 num2) public pure returns(int256) {
        return (num1 * num2);
    }

    function divide(int256 num1, int256 num2) public pure returns(int256) {
        return (num1 / num2);
    }

}