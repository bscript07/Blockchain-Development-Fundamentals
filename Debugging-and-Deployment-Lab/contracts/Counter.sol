// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

contract Counter {
    uint256 private _count;
    address public owner;

    event CountIncremented(uint256 newCount);
    event CountDecremented(uint256 newCount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        _count = 0;
    }

    function getCount() public view returns (uint256) {
        return _count;
    }

    function increment() public onlyOwner {
        _count += 1;
        emit CountIncremented(_count);
    }

    function decrement() public onlyOwner {
        require(_count > 0, "Count cannot be negative");
        _count -= 1;

        emit CountDecremented(_count);
    }
}
