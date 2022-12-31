// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on Chiru Labs

pragma solidity ^0.8.0;

import "./ERC721a.sol";

contract ERC721aCollection is ERC721A, Ownable
{
    string BASE_URI;
    uint MAX_SUPPLY;
    uint PRICE;

    // Constructor

    constructor(
        string memory name,
        string memory symbol,
        string memory base_uri,
        uint max_supply,
        uint _price
    ) ERC721A(name, symbol)
    {
        BASE_URI = base_uri;
        MAX_SUPPLY = max_supply;
        PRICE = _price;
    }

    // Public functions

    function mint(address account, uint amount) public payable
    {
        require(msg.value == price()*amount, "Invalid payment");
        require(totalSupply() + amount < maxSupply(), "Max supply reached");
        _safeMint(account, amount);
    }

    // Owner functions

    function withdraw() public onlyOwner
    {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    // Virtual functions

    function _baseURI() internal view virtual override returns (string memory) {
        return BASE_URI;
    }

    function maxSupply() public view virtual returns (uint) {
        return MAX_SUPPLY;
    }

    function price() public view virtual returns (uint) {
        return PRICE;
    }
}