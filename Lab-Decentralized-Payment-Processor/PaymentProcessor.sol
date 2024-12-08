// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract PaymentProcessor {
    mapping (address => uint256) public balances;

    event PaymentReceived(address indexed customer, uint256 amount);
    event RefundProcessed(address indexed customer, uint256 refundAmount);
    event BonusAdded(address indexed customer, uint256 bonusAmount);

    function receivePayment() external payable {
        require(msg.value > 0, "Payment must be greather than 0");

        balances[msg.sender] += msg.value;
        emit PaymentReceived(msg.sender, msg.value);
    }

    function checkBalance() external view returns(uint256) {
        return balances[msg.sender];
    }

    function refundPayment(address customer, uint256 refundAmount) public virtual {
        require(balances[customer] >= refundAmount, "Insufficient balance");

        balances[customer] -= refundAmount;
        payable(customer).transfer(refundAmount);

        emit RefundProcessed(customer, refundAmount);
    }
}

contract Merchant is PaymentProcessor {
    function refundPayment(address customer, uint256 refundAmount) public override {
        require(balances[customer] >= refundAmount, "Insufficient balance");

        uint256 bonus = refundAmount / 100;
        uint totalRefund = refundAmount + bonus;

        require(address(this).balance >= totalRefund, "Balance too low...");

        balances[customer] -= refundAmount; // prevent re-entrancy
        payable(customer).transfer(totalRefund);

        emit RefundProcessed(customer, refundAmount);
        emit BonusAdded(customer, bonus);
    }
}
