// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../ERC721/ERC721aCollection.sol";

contract MyERC721aCollection is ERC721aCollection {
    constructor()
        ERC721aCollection(
            "My NFT Collection",
            "MNFT", // Name and Symbol
            "https://raw.githubusercontent.com/FilosofiaCodigo/nft-collection-api/master/metadata/", // Base Metadata URI
            10_000, // 10,000 max supply
            0.01 ether
        ) // 0.01 eth mint price
    {}
}
