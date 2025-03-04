// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IStakeX} from "./IStakeX.sol";

contract StakingPool is Ownable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    IERC20 public stakeXToken;
    uint256 public totalStaked;

    struct Staker {
        uint256 balance;
        uint256 rewardDebt;
        uint256 stakingStartTime;
    }

    mapping(address => Staker) public stakers;

    event Deposited(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 reward);
    event Withdrawn(address indexed user, uint256 amount);

    error InsufficientAmount();
    error UnsuccessfullTransfer();
    error RewardsTransferFailed();
    error NoAvailableRewards();
    error InsufficientBalance();

    constructor(address _stakeXToken) {
        stakeXToken = IERC20(_stakeXToken);

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, address(this));
    }

    function deposit(uint256 amount) external {
        if (amount == 0) {
            revert InsufficientAmount();
        }

        bool success = stakeXToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );

        if (!success) {
            revert UnsuccessfullTransfer();
        }

        _calculateAndClaimRewards();

        Staker storage staker = stakers[msg.sender];
        staker.balance += amount;
        staker.stakingStartTime = block.timestamp;

        totalStaked += amount;

        emit Deposited(msg.sender, amount);
    }

    function _mintRewards(address to, uint256 rewardAmount) internal {
        IStakeX(address(stakeXToken)).mint(to, rewardAmount);
    }

    function _calculateAndClaimRewards() internal {
        Staker storage staker = stakers[msg.sender];

        if (staker.balance > 0) {
            uint256 elapsedTime = block.timestamp - staker.stakingStartTime;
            uint256 reward = (((staker.balance * 5) / 100) * elapsedTime) /
                365 days;
            staker.rewardDebt += reward;

            _mintRewards(msg.sender, reward);

            emit RewardsClaimed(msg.sender, reward);
        }

        staker.stakingStartTime = block.timestamp;
    }

    function claimRewards() external {
        Staker storage staker = stakers[msg.sender];
        uint256 rewards = staker.rewardDebt;

        if (rewards == 0) {
            revert NoAvailableRewards();
        }

        staker.rewardDebt = 0;

        _mintRewards(msg.sender, rewards);

        emit RewardsClaimed(msg.sender, rewards);
    }

    function withdraw(uint256 amount) external {
        Staker storage staker = stakers[msg.sender];

        if (amount == 0) {
            revert InsufficientAmount();
        }

        if (staker.balance < amount) {
            revert InsufficientBalance();
        }

        staker.balance -= amount;
        totalStaked -= amount;

        stakeXToken.transfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }
}
