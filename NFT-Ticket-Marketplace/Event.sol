// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

error NoMoreTickets();
error EventEnded();

contract Event is ERC721, Ownable {
    uint256 private _nextTokenId;

    uint256 public immutable date; // Date is timestamp
    address public immutable organizer;
    bool public immutable isPriceCapSet;

    uint256 public biddingTickets;
    uint256 ticketAvailability;
    string public location;

    constructor(
        address minter,
        string memory eventName,
        uint256 _date,
        string memory _location,
        address _organizer,
        bool _isPriceCapSet,
        uint256 _biddingTickets
    ) ERC721(eventName, "") Ownable(minter) {
        require(_date > block.timestamp, "Event date must be in the future");
        require(bytes(_location).length > 0, "Location cannot be empty");

        date = _date;
        location = _location;
        organizer = _organizer;
        isPriceCapSet = _isPriceCapSet;
        biddingTickets = _biddingTickets;
        ticketAvailability = 100;
    }

    function safeMint(address to) public onlyOwner {
        if (block.timestamp > date) {
            revert EventEnded();
        }

        if (_nextTokenId >= ticketAvailability) {
            revert NoMoreTickets();
        }

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function isBiddingAvailable() public view returns (bool) {
        return _nextTokenId < (ticketAvailability + biddingTickets);
    }

    function reduceBiddingTickets() external onlyOwner {
        if (biddingTickets == 0) {
            revert NoMoreTickets();
        }

        biddingTickets -= 1;
    }
}
