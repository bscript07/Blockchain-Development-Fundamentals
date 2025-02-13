# Auction House System

A decentralized auction system consisting of an ERC721 token (NFT) and a AuctionHouse contract

## Contracts

## Instalation

1. Install dependencies

```bash
npm install
```

2. Create `.env` file

```bash
SEPOLIA_URL=your_sepolia_url
PRIVATE_KEY=your_private_key
ETHERSCAN_API_KEY=your_etherscan_api_key
```

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

Deploy both contracts to Sepolia

```bash
npx hardhat deploy --owner <nft_owner> --network sepolia
```

### Deployment Parameters

- `owner`: address of the NFT contract owner

## Contract Verification

Contracts are automatically verified on Etherscan when deployed to Sepolia.

### Verified Contracts (Sepolia)

- NFT: [0xeD6b1a7C6FF035f6fb1272FbEDd30bb0FA6BBc9b](https://sepolia.etherscan.io/address/0xeD6b1a7C6FF035f6fb1272FbEDd30bb0FA6BBc9b)
- AuctionHouse: [0x1Ac41F7C84936a776096B26B0cE0e75060e43DF5](https://sepolia.etherscan.io/address/0x1Ac41F7C84936a776096B26B0cE0e75060e43DF5)
