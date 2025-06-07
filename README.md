# 🏆 Smart Contract Auction System

A decentralized auction platform built with Solidity that supports automatic bid extensions, commission-based deposits, and secure fund management.

## ✨ Features

- 🎯 **Minimum Bid Increment**: 5% higher than current highest bid
- ⏰ **Auto Extension**: Extends by 10 minutes if bid placed in last 10 minutes
- 💰 **Commission System**: 2% commission on deposits for non-winners
- 🔒 **Secure Withdrawals**: Safe fund management for excess bids
- 📜 **Bid History**: Complete tracking of all bids with timestamps
- 👑 **Winner Selection**: Automatic winner determination at auction end

## 🛠️ Developer Setup

### Prerequisites

Make sure you have the following installed:

- 📦 **Node.js** (v16 or higher)
- 🔧 **npm** or **yarn**
- 🦾 **Hardhat** development environment

### Installation Steps

1. **Clone the repository** 📂

2. **Install dependencies** 📋

   ```bash
   npm install
   # or
   yarn install
   ```

3. **Install Hardhat and dependencies** ⚡

   ```bash
   npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
   ```

4. **Create environment file** 🔐

   ```bash
   cp .env.example .env
   ```

   Add your configuration:

   ```env
   PRIVATE_KEY=your_wallet_private_key
   ETHERSCAN_API_KEY=your_etherscan_key
   ```

5. **Compile the contract** 🔨
   ```bash
   npx hardhat compile
   ```

## 🧪 How to Test the Auction

### Local Testing 🏠

1. **Start local Hardhat network** 🚀

   ```bash
   npx hardhat node
   ```

2. **Deploy to local network** 📦

   ```bash
   npx hardhat run scripts/deploy.js --network localhost
   ```

3. **Run test suite** ✅
   ```bash
   npx hardhat test
   ```

### Manual Testing Steps 🔍

#### Step 1: Deploy Contract 🚀

```bash
# Deploy to local network
npx hardhat run scripts/deploy.js --network localhost

# Deploy to Sepolia testnet
npx hardhat run scripts/deploy.js --network sepolia
```

#### Step 2: Interact with Contract 💬

```bash
# Open Hardhat console
npx hardhat console --network localhost

# Get contract instance
const Auction = await ethers.getContractFactory("Auction");
const auction = Auction.attach("YOUR_CONTRACT_ADDRESS");
```

#### Step 3: Test Bidding Flow 💰

```javascript
// Get signers (test accounts)
const [owner, bidder1, bidder2, bidder3] = await ethers.getSigners();

// Check auction info
await auction.getAuctionInfo();

// Place first bid (0.1 ETH)
await auction.connect(bidder1).bid({ value: ethers.parseEther("0.1") });

// Place higher bid (0.2 ETH - meets 5% increment)
await auction.connect(bidder2).bid({ value: ethers.parseEther("0.2") });

// Check current winner
await auction.getWinner();

// Get all bids history
await auction.getAllBids();
```

#### Step 4: Test Edge Cases 🎯

**Test Minimum Bid Increment:**

```javascript
// This should fail (less than 5% increment)
await auction.connect(bidder3).bid({ value: ethers.parseEther("0.21") });
```

**Test Auto Extension:**

```javascript
// Fast forward to near auction end
await network.provider.send("evm_increaseTime", [86400 - 300]); // 5 min before end
await network.provider.send("evm_mine");

// Place bid to trigger extension
await auction.connect(bidder3).bid({ value: ethers.parseEther("0.25") });
```

**Test Withdrawal:**

```javascript
// Non-winner withdraws excess funds
await auction.connect(bidder1).withdrawExcess();
```

#### Step 5: Test Auction End 🏁

```javascript
// Fast forward past auction end
await network.provider.send("evm_increaseTime", [86400]);
await network.provider.send("evm_mine");

// End auction
await auction.endAuction();

// Owner withdraws profits
await auction.connect(owner).withdrawProfits();
```

### Testing Scenarios 📋

| Test Case              | Expected Result                      | Command                           |
| ---------------------- | ------------------------------------ | --------------------------------- |
| 🎯 **Valid Bid**       | Bid accepted, event emitted          | `auction.bid({value: amount})`    |
| ❌ **Low Bid**         | Transaction reverts                  | `auction.bid({value: lowAmount})` |
| ⏰ **Late Extension**  | Auction extended by 10 min           | Bid in last 10 minutes            |
| 💸 **Withdraw Excess** | Funds returned minus commission      | `auction.withdrawExcess()`        |
| 🏆 **End Auction**     | Winner determined, deposits returned | `auction.endAuction()`            |

### Test Network Faucets 🚰

Get test ETH for Sepolia:

- 🌊 [Sepolia Faucet](https://sepoliafaucet.com/)

## 📊 Contract Functions

### Public Functions 🔓

- `bid()` - Place a bid with ETH
- `withdrawExcess()` - Withdraw outbid funds
- `endAuction()` - Finalize auction (after end time)
- `getWinner()` - Get current highest bidder
- `getAllBids()` - Get complete bid history
- `getAuctionInfo()` - Get auction details

### Owner Functions 👑

- `withdrawProfits()` - Withdraw auction proceeds
- `changeAuctionEndTime()` - Modify auction duration

## 🚨 Important Notes

- ⚠️ **Minimum bid increment**: Each bid must be at least 5% higher
- 💰 **Commission**: 2% commission on deposits for non-winners
- ⏰ **Auto-extension**: Auction extends if bid placed in final 10 minutes
- 🔒 **Security**: Direct ETH transfers are rejected - use `bid()` function
- 📝 **Gas optimization**: Consider gas costs for large bid arrays

## 🐛 Troubleshooting

**Common Issues:**

1. **"Bid too low" error** 💸

   - Increase bid amount to meet 5% minimum increment

2. **"Auction ended" error** ⏰

   - Check if auction time has expired

3. **Gas estimation failed** ⛽

   - Check network connection and account balance

4. **Contract verification failed** ❌
   - Wait 30 seconds after deployment before verification
   - Check constructor arguments match deployment

## 📈 Gas Estimates

| Function    | Estimated Gas | Cost (20 gwei) |
| ----------- | ------------- | -------------- |
| Deploy      | ~2,500,000    | ~$15-25        |
| Bid         | ~150,000      | ~$1-3          |
| Withdraw    | ~50,000       | ~$0.50-1       |
| End Auction | ~200,000+     | ~$2-5          |

---
