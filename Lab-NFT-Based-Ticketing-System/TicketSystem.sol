// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract EventTicketNFT is ERC721URIStorage {
    uint256 private _nextTokenId;
    address private _owner;

    struct TicketMetadata {
        string eventName;
        string eventDate;
        string seatNumber;
    }

    mapping(uint256 => TicketMetadata) private _ticketMetadata;

    event MintedTickets(
        address indexed buyer,
        uint256 tokenId,
        string tokenURI
    );
    
    event TransferTickets(
        address indexed from,
        address indexed to,
        uint256 tokenId
    );

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can mint tickets.");
        _;
    }

    modifier onlyOwnerOrApproved(address from) {
        require(
            msg.sender == _owner || msg.sender == from,
            "Not authorized to transfer this ticket"
        );
        _;
    }

    constructor() ERC721("EventTicketNFT", "ETN") {
        _owner = msg.sender;
    }

    function mintTicket(
        address buyer,
        string memory tokenURI,
        string memory eventName,
        string memory eventDate,
        string memory seatNumber
    ) public onlyOwner returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _mint(buyer, tokenId);
        _setTokenURI(tokenId, tokenURI);

        _ticketMetadata[tokenId] = TicketMetadata(
            eventName,
            eventDate,
            seatNumber
        );

        emit MintedTickets(buyer, tokenId, tokenURI);

        return tokenId;
    }

    function getTicketMetadata(uint256 tokenId)
        external
        view
        returns (
            string memory eventName,
            string memory eventDate,
            string memory seatNumber
        )
    {
        TicketMetadata memory metadata = _ticketMetadata[tokenId];

        return (metadata.eventName, metadata.eventDate, metadata.seatNumber);
    }

    function transferTickets(
        address from,
        address to,
        uint256 tokenId
    ) external onlyOwnerOrApproved(from) {
        require(ownerOf(tokenId) == from, "The sender does not own the ticket");

        _safeTransfer(from, to, tokenId, "");

        emit TransferTickets(from, to, tokenId);
    }

    function getOwner() external view returns (address) {
        return _owner;
    }
}
