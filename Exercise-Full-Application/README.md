# Token Crowdsale System

A decentralized token sale system consisting of an ERC20 token (`BitOrangeToken`) and a Crowdsale contract.

## Contracts

### `BitOrangeToken` (CRW)

- ERC20 token with 8 decimals.
- Initial supply: 50,000 CRW (Crowd Token).
- Burn rate: 0.01% (tokens are burned on transfer).
- Symbol: CRW
- Name: Crowd

### `Crowdsale`

- Time-bound sale period (minimum 20 days).
- Configurable token price (tokens per ETH).
- Automatic token distribution on purchase.
- ETH collection with configurable fee receiver.
- Owner-controlled finalization.
- Soft cap: Contributor refunds if soft cap is not reached by the end of the sale.

## Installation

1. **Clone the repository**

```bash
git clone <repository-url>
cd exercise-full-application
```

2. Install dependencies

```bash
npm install
```

3. Create `.env` file

```bash
SEPOLIA_RPC_URL=your_sepolia_rpc_url
PRIVATE_KEY=your_private_key
ETHERSCAN_API_KEY=your_etherscan_api_key
```

### BitOrangeToken Contract

This is an ERC20 token used for the crowdsale. It has the following features:
Burn on transfer: A small percentage (0.01%) of every transfer is burned.
Decimals: The token has 8 decimals.

### Crowdsale Contract

Start and End Times: Configurable start and end time for the crowdsale.
Price: Configurable price per token (in ETH).
Soft Cap: If the soft cap is not reached by the end of the sale, contributors can claim a refund.
Finalization: The owner can finalize the sale and withdraw funds and unsold tokens.

## Testing

Run the test suite:

```bash
npx hardhat test
```

Run test coverage:

```bash
npx hardhat coverage
```

## Deployment

Deploy both contracts to Sepolia:

```bash
--network sepolia \
--startoffset 3600 \
--duration 604800 \
--price 50 \
--tokensforsale 50000 \
--feereceiver 0xYourFeeReceiverAddress
```

## Deployment Parameters

- `startoffset`: Sale start delay in seconds (default: 1000)
- `duration`: Sale duration in seconds (default: 20 days)
- `price`: Tokens per ETH (default: 50)
- `tokensforsale`: Number of tokens for sale (default: 50000)
- `feereceiver`: ETH recipient address (default: deployer)

## Buying Tokens

Use the buy task to purchase tokens:

```
npx hardhat buy \
--network sepolia \
--crowdsale 0xYourCrowdsaleAddress \
--amount 1.5 \
--receiver 0xReceiverAddress
```

## Contract Verification

Contracts are automatically verified on Etherscan when deployed to Sepolia.

### Verified Contracts (Sepolia)

- BitOrangeToken: [0xYourBitOrangeTokenAddress](https://sepolia.etherscan.io/address/0xd5f7cc2903a76d3926b2bb98bc715d9ee5b63107)
- Crowdsale: [0xYourCrowdsaleAddress](https://sepolia.etherscan.io/address/0xc3b6dd962c2ffbdcc66d38e5a90a177fd78b3c46)
