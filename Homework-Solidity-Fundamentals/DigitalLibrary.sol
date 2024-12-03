// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// Struct
struct EBook {
    string title;
    string author;
    uint256 publicationDate;
    uint256 expirationDate;
    string status; // "Active", "Outdated", or "Archived"
    address primaryLibrarian;
    uint256 readCount;
    mapping (address => bool) authorizedLibrarians;
}

contract DigitalLibrary {
    // Storage
    mapping (uint256 => EBook) public eBooks;
    uint256 public nextEBook;

    // Events
    event EBookCreated(uint256 indexed id, string title, string author, address primaryLibrarian);
    event ExpirationDateExtended(uint256 indexed id, uint256 newExpirationDate);
    event EBookArchived(uint256 indexed id);
    event LibrarianAdded(uint256 indexed id, address librarian);

    // Modifier
    modifier onlyAuthorizedLibrarian(uint256 id) {
        require(eBooks[id].primaryLibrarian == msg.sender || eBooks[id].authorizedLibrarians[msg.sender],
                 "Not authorized to perform this action.");_;
    }
    
    // Functions
    function createEBook(string memory _title, string memory _author, uint256 _expirationDate) public {
        require(_expirationDate > block.timestamp, "Expiration date must be in the future.");

        EBook storage newEBook = eBooks[nextEBook];

            newEBook.title = _title;
            newEBook.author = _author;
            newEBook.publicationDate = block.timestamp;
            newEBook.expirationDate = _expirationDate;
            newEBook.status = "Active";
            newEBook.primaryLibrarian = msg.sender;
            newEBook.readCount = 0;

            emit EBookCreated(nextEBook, _title, _author, msg.sender);
            nextEBook++;
    }

    function addAuthorizedLibrarian(uint256 id, address librarian) public {
        require(eBooks[id].primaryLibrarian == msg.sender, "Only the primary librarian can add authorized librarians.");
        eBooks[id].authorizedLibrarians[librarian] = true;

        emit LibrarianAdded(id, librarian);
    }

    function extendExpirationDate(uint256 id, uint256 additionalDays) public onlyAuthorizedLibrarian(id) {
        eBooks[id].expirationDate += additionalDays * 1 days;

        emit ExpirationDateExtended(id, eBooks[id].expirationDate);
    }

    function archiveEBook(uint256 id) public {
        require(eBooks[id].primaryLibrarian == msg.sender, "Only the primary librarian can archive the e-book.");

        eBooks[id].status = "Archived";
        emit EBookArchived(id);
    }

    function checkExpiration(uint256 id) public {
        require(bytes(eBooks[id].title).length > 0, "E-Book does not exists.");

        EBook storage eBook = eBooks[id];
        eBook.readCount++;

        if (block.timestamp > eBook.expirationDate) {
            eBook.status = "Outdated";
        }
    }
}
