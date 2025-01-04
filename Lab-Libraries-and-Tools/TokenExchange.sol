// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SoftCoin is ERC20 {
    constructor() ERC20("SoftCoin", "SFC") {}

    function mint(uint256 amount) external {
        require(amount > 0, "Amount must be greather than zero");

        _mint(msg.sender, amount);
    }
}

contract UniCoin is ERC20, Ownable {
    constructor() ERC20("UniCoin", "UNC") Ownable(msg.sender) {}

    function mint(address account, uint256 amount) external onlyOwner {
        require(account != address(0), "Invalid address");
        require(amount > 0, "Amount must be greather than zero");

        _mint(account, amount);
    }
}

contract TokenExchange {
    SoftCoin public softcoin;
    UniCoin public unicoin;

    constructor(SoftCoin _softcoin, UniCoin _unicoin) {
        softcoin = _softcoin;
        unicoin = _unicoin;
    }

    function trade(uint256 amount) external {
        require(amount > 0, "Amount must be greather than zero");
        require(softcoin.transferFrom(msg.sender, address(this), amount), "SoftCoin transfer failed.");

        unicoin.mint(msg.sender, amount);
    }
}