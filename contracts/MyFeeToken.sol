// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on OpenZeppelin (token/ERC20/ERC20.sol)

pragma solidity 0.8.17;

import "./FeeToken.sol";

contract MyFeeToken is FeeToken
{
    constructor() FeeToken("My Token", "MTKN",
        address(this),
        200, 100, 0,
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D,
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)
    {
    }
}