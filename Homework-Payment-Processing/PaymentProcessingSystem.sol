// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

library PaymentLib {
    error InvalidRecipient();
    error InsufficientAmount();
    error TransferFailed();

    function transferETH(uint256 amount, address to) external {

        if (to == address(0)) {
            revert InvalidRecipient();
        }

        if (address(this).balance < amount) {
            revert InsufficientAmount();
        }

        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }
    }

    function isContract(address account) external view returns (bool isContractAddress) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }

        return size > 0;
    }
}

contract PaymentProcessor is AccessControl, ReentrancyGuard {

    using PaymentLib for uint256;
    address public treasury;
    uint256 public allocationPercentage;

    event TransferCompleted(address indexed recipient, uint256 amountSent, uint256 amountToTreasury);
    event TreasuryAllocation(address indexed treasury, uint256 amountAllocated);

    // Define roles
    bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");

    constructor(address _treasury, uint256 _allocationPercentage) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // Grant DEFAULT_ADMIN_ROLE to the deployer
        _grantRole(TREASURY_ROLE, msg.sender); // Grant TREASURY_ROLE to the deployer
        treasury = _treasury;
        allocationPercentage = _allocationPercentage;
    }

    function setTreasury(address _treasury) external onlyRole(TREASURY_ROLE) {
        treasury = _treasury;
    }

    function setAllocationPercentage(uint256 _allocationPercentage) external onlyRole(TREASURY_ROLE) {
        require(_allocationPercentage <= 100, "Percentage cannot be more 100");
        allocationPercentage = _allocationPercentage;
    }

    function processPayment(address recipient) external payable {
        uint256 totalAmount = msg.value;

        uint256 treasuryAmount = (totalAmount * allocationPercentage) / 100;
        uint256 recipientAmount = totalAmount - treasuryAmount;

        recipientAmount.transferETH(recipient);
        recipientAmount.transferETH(treasury);

        emit TransferCompleted(recipient, recipientAmount, treasuryAmount);
        emit TreasuryAllocation(treasury, treasuryAmount);
    }

    receive() external payable {}
}