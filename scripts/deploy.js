const hre = require("hardhat");
const { ethers } = require("hardhat");

async function main() {
  // Get the deployer
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contract with account:", deployer.address);

  const balance = await deployer.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "ETH");

  const AUCTION_DURATION = 24 * 60 * 60; // 1 day (24 hours)
  const AUCTION_ITEM = "🎨 Cool Pixel Art 🖼️ 🎨";

  console.log("Auction parameters:");
  console.log("- Duration:", AUCTION_DURATION, "seconds (1 day)");
  console.log("- Item:", AUCTION_ITEM);

  console.log("\nDeploying auction contract...");

  const Auction = await ethers.getContractFactory("Auction");
  const auction = await Auction.deploy(AUCTION_DURATION, AUCTION_ITEM);

  // This awaits for confirmation
  await auction.waitForDeployment();

  const contractAddress = await auction.getAddress();
  console.log("✅ Contract deployed at:", contractAddress);

  // contract information
  console.log("\n📋 Contract information:");
  console.log("- Network:", hre.network.name);
  console.log("- Contract address:", contractAddress);
  console.log("- Owner address:", await auction.owner());
  console.log("- Auction item:", await auction.auctionItem());

  const endTime = await auction.auctionEndTime();
  const endDate = new Date(Number(endTime) * 1000);
  console.log("- End date:", endDate.toLocaleString());

  // Verify contract on Etherscan (only on public networks)
  if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
    console.log("\n⏳ Waiting 30 seconds before verifying contract...");
    await new Promise((resolve) => setTimeout(resolve, 30000));

    try {
      await hre.run("verify:verify", {
        address: contractAddress,
        constructorArguments: [AUCTION_DURATION, AUCTION_ITEM],
      });
      console.log("✅ Contract verified on Etherscan");
    } catch (error) {
      console.log("❌ Error verifying contract:", error.message);
      console.log("You can verify manually with these parameters:");
      console.log("- Constructor args:", [AUCTION_DURATION, AUCTION_ITEM]);
    }
  }

  // useful commands
  console.log("\n🔧 Useful commands:");
  console.log(
    `- View on Etherscan: https://sepolia.etherscan.io/address/${contractAddress}`
  );
  console.log(
    `- Interact with contract: npx hardhat console --network ${hre.network.name}`
  );

  //  contract address to file
  const fs = require("fs");
  const deploymentInfo = {
    network: hre.network.name,
    contractAddress: contractAddress,
    owner: deployer.address,
    deploymentDate: new Date().toISOString(),
    auctionItem: AUCTION_ITEM,
    auctionDuration: AUCTION_DURATION,
    constructorArgs: [AUCTION_DURATION, AUCTION_ITEM],
  };

  fs.writeFileSync(
    `deployment-${hre.network.name}.json`,
    JSON.stringify(deploymentInfo, null, 2)
  );

  console.log(`\n💾 Information saved to: deployment-${hre.network.name}.json`);

  return contractAddress;
}

// Execute the script
main()
  .then((contractAddress) => {
    console.log("\n🎉 Deployment completed successfully!");
    console.log("Contract address:", contractAddress);
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Error during deployment:", error);
    process.exit(1);
  });
