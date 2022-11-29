// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../ERC20/UniswapV3FeeToken.sol";

contract MyUniswapV3FeeToken is UniswapV3FeeToken
{
    constructor() UniswapV3FeeToken(
        "My Token", "MTKN",                         // Name and Symbol
        1_000_000_000 ether,                        // 1 billion supply
        msg.sender,                                 // Vault Address
        100, 200,                                   // Fees: 1% buy 2% P2P
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, // Base token: WETH
        1000)                                       // Initial rate: 1 Base Tokens = 1000 tokens
    {
    }
}