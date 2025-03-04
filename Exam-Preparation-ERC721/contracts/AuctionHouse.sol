// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

struct Auction {
    uint256 tokenId;
    address nftAddress;
    uint256 minPrice;
    uint256 startTime;
    uint256 endTime;
    uint256 bidIncrement;
    uint256 timeExtensionWindow;
    uint256 timeExtensionIncrease;
    address seller;
    bool nftClaimed;
    bool rewardClaimed;
}

error CannotBeZero();
error InvalidStartTime();
error InvalidEndTime(string argument);
error InsufficientBid();
error NotInBidPeriod();
error NotValidAuction();
error AuctionUnfinished();
error NotClaimer();
error AlreadyClaimed();
error HighestBidder();
error NoWinner();
error NotSeller();

contract AuctionHouse is Ownable {
    uint256 MIN_AUCTION_DURATION = 1 days;
    uint256 MAX_AUCTION_DURATION = 60 days;

    uint256 private _nextAuctionId;

    mapping(uint256 => Auction) public auctions;
    mapping(uint256 auctionId => mapping(address bidder => uint256 bid))
        public bids;
    mapping(uint256 auctionId => address highestBidder) public highestBidders;

    event AuctionCreated(uint256 indexed auctionId);
    event NewBid(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 bid
    );
    event NftClaimed(uint256 indexed auctionId);
    event BidClaimed(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 bid
    );
    event RewardClaimed(uint256 indexed auctionId, uint256 reward, uint256 fee);

    constructor() Ownable(msg.sender) {}

    function createAuction(
        uint256 tokenId,
        address tokenAddress,
        uint256 minPrice,
        uint256 startTime,
        uint256 endTime,
        uint256 bidIncrement,
        uint256 timeExtensionWindow,
        uint256 timeExtensionIncrease
    ) external onlyOwner {
        if (minPrice == 0) {
            revert CannotBeZero();
        }

        if (startTime < block.timestamp) {
            revert InvalidStartTime();
        }

        if (endTime < startTime + MIN_AUCTION_DURATION) {
            revert InvalidEndTime("Too low");
        }

        if (endTime > startTime + MAX_AUCTION_DURATION) {
            revert InvalidEndTime("Too high");
        }

        uint256 auctionId = _nextAuctionId++;
        auctions[auctionId] = Auction({
            tokenId: tokenId,
            nftAddress: tokenAddress,
            minPrice: minPrice,
            startTime: startTime,
            endTime: endTime,
            bidIncrement: bidIncrement,
            timeExtensionWindow: timeExtensionWindow,
            timeExtensionIncrease: timeExtensionIncrease,
            seller: msg.sender,
            nftClaimed: false,
            rewardClaimed: false
        });

        // @note The NFT needs allowance
        ERC721(tokenAddress).transferFrom(msg.sender, address(this), tokenId);

        emit AuctionCreated(auctionId);
    }

    function bid(uint256 auctionId) external payable {
        Auction storage auction = auctions[auctionId];

        if (auction.nftAddress == address(0)) {
            revert NotValidAuction();
        }

        if (
            block.timestamp < auction.startTime ||
            block.timestamp > auction.endTime
        ) {
            revert NotInBidPeriod();
        }

        uint256 newBid = bids[auctionId][msg.sender] + msg.value;
        if (
            newBid < auction.minPrice ||
            (highestBidders[auctionId] != address(this) &&
                newBid <
                bids[auctionId][highestBidders[auctionId]] +
                    auction.bidIncrement)
        ) {
            revert InsufficientBid();
        }

        if (block.timestamp > auction.endTime - auction.timeExtensionWindow) {
            auction.endTime += auction.timeExtensionIncrease;
        }

        bids[auctionId][msg.sender] = newBid;
        highestBidders[auctionId] = msg.sender;

        emit NewBid(auctionId, msg.sender, newBid);
    }

    function claimNFT(uint256 auctionId) external auctionFinished(auctionId) {
        Auction storage auction = auctions[auctionId];
        // _ensureAuctionFinished[auctionId];

        if (auction.nftClaimed) {
            revert AlreadyClaimed();
        }

        address highestBidder = highestBidders[auctionId];
        if (
            msg.sender != highestBidder &&
            highestBidders[auctionId] != address(0) &&
            msg.sender != auction.seller
        ) {
            revert NotClaimer();
        }

        auction.nftClaimed = true;

        address receiver = msg.sender == highestBidder
            ? highestBidder
            : auction.seller;
        ERC721(auction.nftAddress).safeTransferFrom(
            address(this),
            receiver,
            auction.tokenId
        );

        emit NftClaimed(auctionId);
    }

    function claimBid(uint256 auctionId) external {
        uint256 userBid = bids[auctionId][msg.sender];

        if (highestBidders[auctionId] == msg.sender) {
            revert HighestBidder();
        }

        if (bids[auctionId][msg.sender] != 0) {
            bids[auctionId][msg.sender] = 0;
            transferETH(payable(msg.sender), userBid);
        }

        emit BidClaimed(auctionId, msg.sender, userBid);
    }

    function claimReward(
        uint256 auctionId
    ) external auctionFinished(auctionId) {
        uint256 reward = bids[auctionId][highestBidders[auctionId]];

        if (reward == 0) {
            revert NoWinner();
        }

        Auction storage auction = auctions[auctionId];
        if (auction.rewardClaimed) {
            revert AlreadyClaimed();
        }

        if (msg.sender != auction.seller) {
            revert NotSeller();
        }

        auction.rewardClaimed = true;

        uint256 fee = (reward / 100); // 1% fee for creator
        if (fee > 0) {
            transferETH(payable(owner()), fee);
        }

        transferETH(payable(msg.sender), reward - fee);

        emit RewardClaimed(auctionId, reward, fee);
    }

    function transferETH(address payable to, uint256 amount) private {
        (bool sent, ) = to.call{value: amount}("");

        require(sent, "Failed to send ETH");
    }

    modifier auctionFinished(uint256 auctionId) {
        if (block.timestamp <= auctions[auctionId].endTime) {
            revert AuctionUnfinished();
        }

        _;
    }
}
