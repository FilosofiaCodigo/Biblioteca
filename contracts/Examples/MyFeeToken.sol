// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../ERC20/UniswapV2FeeToken.sol";

contract MyFeeToken is UniswapV2FeeToken
{
    constructor() UniswapV2FeeToken("My Token", "MTKN",      // Name and Symbol
        1_000_000_000 ether,                        // 1 billion supply
        address(this),                              // Vault Address
        100, 200, 0,                                // Fees: 2% buy 1% sell 0% P2P
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, // Router Address
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48) // Base Token Address
    {
    }
}