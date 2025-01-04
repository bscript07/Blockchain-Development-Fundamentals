// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

struct Card {
    uint256 id;
    uint256 power;
    string name;
}

library CollectionLib {
    function exists(Card[] memory cards, uint256 id) internal pure returns (bool doesExist) {
        uint256 cardsLength = cards.length;
        assert(cardsLength < 100);

        for (uint256 i = 0; i < cardsLength; i++) {
            if (cards[i].id == id) {
                return true;
            }
        }
        return false;
    }

    function removeAt(Card[] storage cards, uint256 idx) internal {
        uint256 cardsLength = cards.length;

        require(idx < cardsLength, "Invalid index provided.");

        cards[idx] = cards[cardsLength - 1];
        cards.pop();
    }
}

contract CollectibleCardLibrary {
    mapping(address => Card[]) public collections;
    using CollectionLib for Card[];
    address public owner;

    error AlreadyExists();

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner.Sorry!");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addCard(uint256 id, uint256 power, string calldata name) external onlyOwner {
        // Verify card uniquenes
        if (collections[msg.sender].exists(id)) {
            revert AlreadyExists();
        }

        // Add the new card to the collection
        collections[msg.sender].push(Card({
            id: id,
            power: power,
            name: name
        }));
    }

    function removeCardAt(uint256 idx) external onlyOwner {
        collections[msg.sender].removeAt(idx);
    }
}