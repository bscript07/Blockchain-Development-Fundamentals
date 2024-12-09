// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Asset {
    string symbol;
    string name;
    uint256 initialSupply;
    address owner;

    mapping (address => uint256) public balances;

    constructor(
        string memory _symbol,
        string memory _name,
        uint256 _initialSupply,
        address _owner
    ) {
        symbol = _symbol;
        name = _name;
        initialSupply = _initialSupply;
        owner = _owner;

        // Assign the entire initial supply to the owner
        balances[_owner] = _initialSupply;
    }

    function transfer(address _to, uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        require(_to != address(0), "Invalid recipient address!");

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }
}

contract AssetFactory is Asset {
    mapping (string => address) private assetsBySymbol;

    event AssetCreated(string symbol, address assetAddress);

    constructor() Asset("", "", 0, address(0)) {
        // Initializing with empty values
    }

    function createAsset(
        string memory _symbol,
        string memory _name,
        uint256 _initialSupply
        ) public {
            require(assetsBySymbol[_symbol] == address(0), "Asset with this symbol already exists.");

            // Deploy a new Asset contract instance using inheritance
            Asset newAsset = new Asset(_symbol, _name, _initialSupply, msg.sender);

            // Store the address of the newly created asset
            assetsBySymbol[_symbol] = address(newAsset);

            emit AssetCreated(_symbol, address(newAsset));
    }

    function retrieveAssetAddress(string memory _symbol) public view returns (address) {
        return assetsBySymbol[_symbol];
    }

    function transferAssets(string memory _symbol, address _to, uint256 _amount) public {

        address assetAddress = assetsBySymbol[_symbol];
        require(assetAddress != address(0), "Asset not found!");

        // Call the transfer function of the specified Asset contract
        Asset(assetAddress).transfer(_to, _amount);
    }
}