// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on OpenZeppelin (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./ERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint amount) external;
}