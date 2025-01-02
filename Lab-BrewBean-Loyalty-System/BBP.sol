// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface ILoyaltyPoints {
    function rewardPoints(address customer, uint256 amount) external;
    function redeemPoints(address customer, uint256 amount) external;
}

abstract contract BaseLoyaltyProgram is ERC20, ILoyaltyPoints {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function _authorizeReward(address customer) internal virtual returns (bool);
    mapping (address => uint256) private _loyaltyPoints;

    function rewardPoints(address customer, uint256 amount) external override {
        require(_authorizeReward(msg.sender), "Customer not eligible for reward.");
        require(amount > 0, "Amount must be greater than zero");

        _mint(customer, amount);
        
        emit PointsRewarded(msg.sender, customer, amount);
    } 

    function redeemPoints(address customer, uint256 amount) external override {
        require(balanceOf(customer) >= amount, "Insufficient loyalty points.");
        require(_authorizeReward(customer), "Customer not be eligible for redemption");

        _burn(customer, amount);
        emit PointsRedeemed(customer, amount);
    }

    event PointsRewarded(address indexed cofe, address indexed customer, uint256 amount);
    event PointsRedeemed(address indexed customer, uint256 amount);
}

contract BrewBeanPoints is BaseLoyaltyProgram, Ownable {

    mapping (address => bool) private _authorizedCoffes;

    constructor () BaseLoyaltyProgram("Brew Bean Points", "BBP") Ownable(msg.sender) {}

    modifier onlyPartner() {
        require(_authorizedCoffes[msg.sender], "Caller is not the authorized partner");
        _;
    }

    function authorizeCoffe(address coffee) external onlyOwner {
        _authorizedCoffes[coffee] = true;

        emit PartnerAuthorized(coffee);
    }

    function revokeCoffe(address coffee) external onlyOwner {
        _authorizedCoffes[coffee] = false;

        emit PartnerRevoked(coffee);
    }

    function _authorizeReward(address caller) internal view override returns (bool) {
        return _authorizedCoffes[caller];
    }

    event PartnerAuthorized(address indexed coffee);
    event PartnerRevoked(address indexed coffee);
}