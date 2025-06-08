// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Auction {
    struct Bid {
        address bidder;
        uint256 amount;
        uint256 timestamp;
    }

    address public owner;
    address public highestBidder;
    uint256 public highestBid;
    uint256 public auctionEndTime;
    bool public auctionEnded;
    string public auctionItem;

    // Constants
    uint256 private constant MINIMUM_BID_INCREMENT = 5; // 5% higher than the current highest bid
    uint256 private constant COMMISSION_RATE = 2; // 2% commission  on deposits
    uint256 private constant TIME_EXTENSION = 10 minutes; // 10 minutes extension for bids made in the last 10 minutes
    uint256 private constant EXTENSION_THRESHOLD = 10 minutes; // Threshold for extending the auction

    // Mappings to manage bids and deposits
    mapping(address => uint256) public pendingReturns;
    mapping(address => uint256) public totalDeposits;

    // bid history
    Bid[] public bids;

    // Events
    event NewBid(address indexed bidder, uint256 amount, uint256 timestamp);
    event AuctionEnded(address winner, uint256 amount);
    event DepositReturned(address indexed bidder, uint256 amount);
    event AuctionExtended(uint256 newEndTime);

    // Modifiers
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the owner can execute this function"
        );
        _;
    }

    modifier onlyWhileOpen() {
        require(
            block.timestamp < auctionEndTime && !auctionEnded,
            "The auction has ended"
        );
        _;
    }

    modifier onlyAfterEnd() {
        require(
            block.timestamp >= auctionEndTime || auctionEnded,
            "The auction has not ended yet"
        );
        _;
    }

    /**
     * @dev Constructor that initializes the auction
     * @param _biddingTime Duration of the auction in seconds
     * @param _auctionItem Description of the item to auction
     */
    constructor(uint256 _biddingTime, string memory _auctionItem) {
        require(_biddingTime > 0, "Auction time must be greater than 0");
        require(bytes(_auctionItem).length > 0, "Must specify an item");

        owner = msg.sender;
        auctionEndTime = block.timestamp + _biddingTime;
        auctionItem = _auctionItem;
        auctionEnded = false;
    }

    /**
     * @dev Function to place a bid
     */
    function bid() external payable onlyWhileOpen {
        require(msg.value > 0, "Bid must be greater than 0");

        // Calculate the minimum required bid
        uint256 minimumBid = highestBid +
            ((highestBid * MINIMUM_BID_INCREMENT) / 100);

        require(
            msg.value >= minimumBid,
            "Bid must be at least 5% higher than current bid"
        );
        uint256 totalBidAmount = msg.value + pendingReturns[msg.sender];

        require(
            totalBidAmount >= minimumBid,
            "Total bid is not sufficient"
        );

        totalDeposits[msg.sender] += msg.value;

        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = totalBidAmount;
        pendingReturns[msg.sender] = 0;
        bids.push(
            Bid({
                bidder: msg.sender,
                amount: totalBidAmount,
                timestamp: block.timestamp
            })
        );

        // Check if the bid was made in the last 10 minutes
        if (auctionEndTime - block.timestamp <= EXTENSION_THRESHOLD) {
            auctionEndTime += TIME_EXTENSION;
            emit AuctionExtended(auctionEndTime);
        }

        emit NewBid(msg.sender, totalBidAmount, block.timestamp);
    }

    /**
     * @dev Allows participants to withdraw excess bids
     */
    function withdrawExcess() external {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "No funds to withdraw");

        pendingReturns[msg.sender] = 0;
        totalDeposits[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Error sending funds");

        emit DepositReturned(msg.sender, amount);
    }

    /**
     * @dev Ends the auction and returns deposits - only callable by the owner
     */
   function endAuction() external onlyOwner onlyAfterEnd {
        require(!auctionEnded, "The auction has already been finalized");

        auctionEnded = true;
        emit AuctionEnded(highestBidder, highestBid);

        // Return deposits to non-winners
        _returnDeposits();
    }

    /**
     * @dev Internal function to return deposits with commission after the auction ends
     */
    function _returnDeposits() private {
        for (uint256 i = 0; i < bids.length; i++) {
            address bidder = bids[i].bidder;

            // Skip if it's the winner or already processed
            if (bidder == highestBidder || totalDeposits[bidder] == 0) {
                continue;
            }

            uint256 depositAmount = totalDeposits[bidder];
            uint256 commission = (depositAmount * COMMISSION_RATE) / 100;
            uint256 returnAmount = depositAmount - commission;

            // Clear the deposit
            totalDeposits[bidder] = 0;
            pendingReturns[bidder] = 0;

            // Send the refund
            if (returnAmount > 0) {
                (bool success, ) = payable(bidder).call{value: returnAmount}(
                    ""
                );
                if (success) {
                    emit DepositReturned(bidder, returnAmount);
                }
            }
        }
    }

    /**
     * @dev Allows the owner to withdraw profits
     */
    function withdrawProfits() external onlyOwner {
        require(auctionEnded, "The auction must have ended");

        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Error sending funds");
    }
    
    /**
     * @dev Gets the current winner
     * @return winner Winner's address
     * @return amount Winning bid amount
     */
    function getWinner()
        external
        view
        returns (address winner, uint256 amount)
    {
        return (highestBidder, highestBid);
    }

    /**
     * @dev Gets all bids made
     * @return bidders Array of bidder addresses
     * @return amounts Array of bid amounts
     * @return timestamps Array of bid timestamps
     */
    function getAllBids()
        external
        view
        returns (
            address[] memory bidders,
            uint256[] memory amounts,
            uint256[] memory timestamps
        )
    {
        uint256 length = bids.length;
        bidders = new address[](length);
        amounts = new uint256[](length);
        timestamps = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            bidders[i] = bids[i].bidder;
            amounts[i] = bids[i].amount;
            timestamps[i] = bids[i].timestamp;
        }

        return (bidders, amounts, timestamps);
    }

    /**
     * @dev Gets general auction information
     */
    function getAuctionInfo()
        external
        view
        returns (
            string memory item,
            uint256 endTime,
            bool ended,
            address currentWinner,
            uint256 currentHighestBid,
            uint256 totalBids
        )
    {
        return (
            auctionItem,
            auctionEndTime,
            auctionEnded,
            highestBidder,
            highestBid,
            bids.length
        );
    }

    /**
     * @dev Function to receive Ether directly bc no bid history otherwise (rejects direct payments)
     */
    receive() external payable {
        revert("Use the bid() function to place bids");
    }
}