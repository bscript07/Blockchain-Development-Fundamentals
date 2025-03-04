# StakeX and StakingPool Contracts

## Description

This project includes two Solidity contracts:

1. **StakeX** - An ERC20 token with minting capabilities.
2. **StakingPool** - A staking contract that allows users to deposit tokens, earn rewards, and withdraw them.

These contracts are designed to enable users to stake StakeX tokens and earn rewards based on the time their tokens have been staked.

## Prerequisites

To run this project, you need to have the following installed:

- **Node.js** (v14.x or higher)
- **Hardhat** (a development framework for Ethereum)

## Installation

Follow these steps to set up the project:

### 1. Clone the repository

Clone the project to your local machine:

```bash
git clone https://github.com/your-username/StakeX.git
cd StakeX
```

### 2. Install dependencies

```bash
npm install
```

### 3. Deploy the contracts

```bash
npx hardhat deploy --network sepolia
```

### 4. Contract Verification

```bash
npx hardhat verify --network sepolia <StakeX_contract_address>
npx hardhat verify --network sepolia <StakingPool_contract_address> <StakeX_contract_address>
```

### 5. Verified Contracts

StakeX: [0x3A94e37B603806ED91199DfB76191102eCBC9152](https://etherscan.io/address/0x3A94e37B603806ED91199DfB76191102eCBC9152)

StakingPool: [0xD91f0908DD9b187822C90E91F1cFc89c1B0A6840](https://etherscan.io/address/0xD91f0908DD9b187822C90E91F1cFc89c1B0A6840)
