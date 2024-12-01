// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MessageBoard {
    mapping(address => string[]) public messages;

    function storeMessages(string memory message) external {
        messages[msg.sender].push(message);
    }

    function previewMessage(string memory message) external pure returns (string memory) {
        return string (abi.encodePacked("Draft: ", message));
    }
}