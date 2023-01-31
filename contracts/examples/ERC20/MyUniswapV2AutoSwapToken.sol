// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../ERC20/UniswapV2AutoSwapToken.sol";

contract MyUniswapV2AutoSwapToken is UniswapV2AutoSwapToken
{
    constructor() UniswapV2AutoSwapToken(
        "My Token", "MTKN",                         // Name and Symbol
        1_000_000_000 ether,                        // 1 billion supply
        100, 200, 50,                               // Fees: 1% buy 2% sell 0.5% P2P
        msg.sender,                                 // AutoSwap Receiver
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, // Router Address: Uniswap V2
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, // Base Token Address: USDC
        100)                                        // 1% in tokens before swap percent
    {
    }
}