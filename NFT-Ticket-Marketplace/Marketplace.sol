// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Event} from "./Event.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error InvalidInput(string info);
error AlreadyListed();
error MustBeOrganizer();
error WrongBuyingOption();
error ProfitDistributionFailed();

enum BuyingOptions {
    FixedPrice,
    BiddingPrice
}

struct EventData {
    uint256 ticketPrice;
    BuyingOptions salesType;
    uint256 salesEnd; // timestamp
}

struct Bid {
    address bidder;
    uint256 amount;
}

contract Marketplace is ReentrancyGuard {
    uint256 public constant MIN_SALE_PERIOD = 24 hours;

    uint256 public constant SALE_FEE = 0.1 ether;
    address public immutable feeCollector;

    mapping(address => EventData) public events;
    mapping(address => uint256) public profits;

    mapping (address => Bid[]) public bids; // mapping array of bids
    mapping (address => uint256) public highestBid; // track the highest bid for each event
    mapping (address => address) public highestBidder; // track the highest bidder for each event
    mapping (address => uint256) public minimumBid; // store minimum bid price for events
    mapping (address => uint256) public bidEndTime; // store bidding period end time for events

    event NewEvent(address indexed newEvent);

    constructor(address _feeCollector) {
        feeCollector = _feeCollector;
    }

    function createEvent(
        string memory eventName,
        uint256 _date,
        string memory _location,
        uint256 _ticketPrice,
        BuyingOptions salesType,
        uint256 salesEnd,
        uint256 _biddingTickets
    ) external {

        require(bytes(eventName).length > 0, "Event name cannot be empty");
        require(bytes(_location).length > 0, "Location cannot be empty");
        require(_date > block.timestamp, "Event date must be in the future");

        address newEvent = address(
            new Event(address(this), eventName, _date, _location, msg.sender, true, _biddingTickets)
        );

        emit NewEvent(newEvent);

        _listEvent(newEvent, _ticketPrice, salesType, salesEnd);
    }

    function listEvent(
        address newEvent,
        uint256 _ticketPrice,
        BuyingOptions salesType,
        uint256 salesEnd
    ) external {
        if (msg.sender != Event(newEvent).organizer()) {
            revert MustBeOrganizer();
        }

        _listEvent(newEvent, _ticketPrice, salesType, salesEnd);
    }

    function _listEvent(
        address newEvent,
        uint256 _ticketPrice,
        BuyingOptions salesType,
        uint256 salesEnd
    ) internal {
        // TODO: Ensure External Event contract is compatible with IEvent
        if (salesEnd < block.timestamp + MIN_SALE_PERIOD) {
            revert InvalidInput("salesEnd is invalid");
        }

        if (salesType == BuyingOptions.BiddingPrice) {
            if (_ticketPrice < SALE_FEE) {
                 revert InvalidInput("Minimum bid price must be >= SALE_FEE");
            }
            minimumBid[newEvent] = _ticketPrice;
            bidEndTime[newEvent] = salesEnd;
        }

        if (_ticketPrice < SALE_FEE) {
            revert InvalidInput("ticketPrice >= SALE_FEE");
        }

        if (events[newEvent].salesEnd != 0) {
            revert AlreadyListed();
        }

        events[newEvent] = EventData({
            ticketPrice: _ticketPrice,
            salesType: salesType,
            salesEnd: salesEnd
        });
    }

    function buyTicket(address _event) external payable {

        if (events[_event].salesType != BuyingOptions.FixedPrice) {
            revert WrongBuyingOption();
        }

        if (msg.value != events[_event].ticketPrice) {
            revert InvalidInput("wrong value");
        }

        profits[Event(_event).organizer()] += msg.value - SALE_FEE;
        profits[feeCollector] += SALE_FEE;

        Event(_event).safeMint(msg.sender);
    }

    function placeBid(address _event) external payable nonReentrant {
        if (events[_event].salesType != BuyingOptions.BiddingPrice) {
            revert WrongBuyingOption();
        }

        if (block.timestamp > bidEndTime[_event]) {
            revert InvalidInput("Bidding period has ended");
        }

        if (msg.value <= minimumBid[_event] || msg.value <= highestBid[_event]) {
            revert InvalidInput("Bid amount too low");
        }

        if (highestBidder[_event] != address(0)) {
            (bool refundSuccess, ) = highestBidder[_event].call{value: highestBid[_event]}("");
            require(refundSuccess, "Refund failed");
        }

        highestBid[_event] = msg.value;
        highestBidder[_event] = msg.sender;

        bids[_event].push(Bid({bidder: msg.sender, amount: msg.value}));
    }

    function finalizeBidding(address _event) external nonReentrant {
        if (msg.sender != Event(_event).organizer()) {
            revert MustBeOrganizer();
        }

        if (block.timestamp <= bidEndTime[_event]) {
            revert InvalidInput("Bidding period is still active");
        }

        if (highestBidder[_event] == address(0)) {
            revert InvalidInput("No bids placed");
        }

        // Transfer sale fee and remaining profit
        uint256 saleFee = SALE_FEE;
        uint256 profit = highestBid[_event] - saleFee;

        profits[Event(_event).organizer()] += profit;
        profits[feeCollector] += saleFee;

        Event(_event).safeMint(highestBidder[_event]);

        // Reset biding data
        delete highestBid[_event];
        delete highestBidder[_event];
        delete bids[_event];
    }

    function refundBidders(address _event) external {
        uint256 refundAmount;

        for (uint256 i = 0; i < bids[_event].length; i++) {
            if (bids[_event][i].bidder == msg.sender && bids[_event][i].bidder != highestBidder[_event]) {
                refundAmount += bids[_event][i].amount;
                delete bids[_event][i];
            }
        }

        require(refundAmount > 0, "No refunds available");
        (bool success, ) = msg.sender.call{value: refundAmount}("");
        require(success, "Refund failed");
    }

    function withdrawProfit(address to) external payable {

        // Implement logic for profits from biddings
        uint256 profit = profits[msg.sender];
        profits[msg.sender] = 0; // prevent reentrancy attack

        (bool success, ) = to.call{value: profit}("");

        if (!success) {
            revert ProfitDistributionFailed();
        }
    }
}