# 🏆 Smart Contract Auction System

A decentralized auction platform built with Solidity that supports automatic bid extensions, commission-based deposits, and secure fund management.

## ✨ Features

- 🎯 **Minimum Bid Increment**: 5% higher than current highest bid
- ⏰ **Auto Extension**: Extends by 10 minutes if bid placed in last 10 minutes
- 💰 **Commission System**: 2% commission on deposits for non-winners
- 🔒 **Secure Withdrawals**: Safe fund management for excess bids
- 📜 **Bid History**: Complete tracking of all bids with timestamps
- 👑 **Winner Selection**: Automatic winner determination at auction end

## 🛠️ Local Setup

### Prerequisites

- 📦 **Node.js** (v16 or higher)
- 🧶 **Yarn** (v4.6.0)
- 🦾 **Hardhat** development environment

### Installation

1. **Clone the repository**

2. **Install dependencies**

   ```bash
   yarn install
   yarn add --dev hardhat @nomicfoundation/hardhat-toolbox
   ```

3. **Create environment file**

   ```bash
   cp .env.example .env
   ```

   Add your configuration:

   ```env
   PRIVATE_KEY=your_wallet_private_key
   ETHERSCAN_API_KEY=your_etherscan_key
   ```

4. **Compile contracts**
   ```bash
   yarn compile
   ```

## 📋 Available Scripts

- `yarn compile` - Compile smart contracts
- `yarn test` - Run test suite
- `yarn deploy:localhost` - Deploy to local network
- `yarn deploy:sepolia` - Deploy to Sepolia testnet
- `yarn node` - Start local Hardhat node
- `yarn console:localhost` - Open Hardhat console
- `yarn clean` - Clean artifacts

## 📊 Contract Functions

### Public Functions

- `bid()` - Place a bid with ETH
- `withdrawExcess()` - Withdraw outbid funds
- `endAuction()` - Finalize auction (after end time)
- `getWinner()` - Get current highest bidder
- `getAllBids()` - Get complete bid history
- `getAuctionInfo()` - Get auction details

### Owner Functions

- `withdrawProfits()` - Withdraw auction proceeds
- `changeAuctionEndTime()` - Modify auction duration

## 🚨 Important Rules

- ⚠️ **Minimum bid increment**: Each bid must be at least 5% higher
- 💰 **Commission**: 2% commission on deposits for non-winners
- ⏰ **Auto-extension**: Auction extends if bid placed in final 10 minutes
- 🔒 **Security**: Direct ETH transfers rejected - use `bid()` function

## 🐛 Common Issues

1. **"Bid too low" error** - Increase bid to meet 5% minimum increment
2. **"Auction ended" error** - Check if auction time has expired
3. **Gas estimation failed** - Check network connection and balance
4. **Verification failed** - Wait 30 seconds after deployment

## 📈 Gas Estimates

| Function    | Estimated Gas | Cost (20 gwei) |
| ----------- | ------------- | -------------- |
| Deploy      | ~2,500,000    | ~$15-25        |
| Bid         | ~150,000      | ~$1-3          |
| Withdraw    | ~50,000       | ~$0.50-1       |
| End Auction | ~200,000+     | ~$2-5          |
