// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0; 

import "hardhat/console.sol"; 

contract Token {
     mapping(address => uint256) 
     private _balances; 
     constructor() { _balances[msg.sender] = 1000000; } 
     
     function transfer(address to, uint256 amount) public {

        require(to != address(0), "Cannot transfer to the zero address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        require(msg.sender != to, "Cannot transfer to themselves");

        console.log("Sender balance before transfer:", _balances[msg.sender]);
        console.log("Receiver's address before transfer:", to);
        console.log("Receiver's balance before transfer:", _balances[to]);
        console.log("Amount being transfered", amount);

         _balances[msg.sender] -= amount;
         _balances[to] += amount; 

        console.log("Sender balance after transfer:", _balances[msg.sender]);
        console.log("Receiver balance after transfer", _balances[to]);
    } 
    
     function balanceOf(address account) public view returns (uint256) {
         return _balances[account]; 
    }
}