# Biblioteca

Smart Contract Library

## Keep in mind

* This contracts are based on OpenZeppelin libraries but changed `private` variables to `internal` for flexibility
* All contracts are `Ownable`
* All percentage numbers are 2 digit decimals (e.g. 150 percent is 1.5%)

## ERC20 Tokens

### Uniswap V2 Fee Token

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "biblioteca/contracts/ERC20/UniswapV2FeeToken.sol";

contract MyUniswapV2FeeToken is UniswapV2FeeToken
{
    constructor() UniswapV2FeeToken(
        "My Token", "MTKN",                         // Name and Symbol
        1_000_000_000 ether,                        // 1 billion supply
        address(this),                              // Vault Address
        100, 200, 0,                                // Fees: 2% buy 1% sell 0% P2P
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, // Router Address
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48) // Base Token Address
    {
    }
}
```


### Uniswap V2 AutoSwap Token

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "biblioteca/contracts/ERC20/UniswapV2AutoSwapToken.sol";

contract MyUniswapV2AutoSwapToken is UniswapV2AutoSwapToken
{
    constructor() UniswapV2AutoSwapToken(
        "My Token", "MTKN",                         // Name and Symbol
        1_000_000_000 ether,                        // 1 billion supply
        100, 200, 0,                                // Fees: 2% buy 1% sell 0% P2P
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, // Router Address
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,// Base Token Address
        msg.sender,                                 // AutoSwap Recipient
        100)                                        // 1% in tokens before swap percent
    {
    }
}
```

### Balancer V2 Fee Token

```
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "biblioteca/contracts/ERC20/BalancerV2FeeToken.sol";

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../ERC20/BalancerV2FeeToken.sol";

contract MyBalancerFeeToken is BalancerV2FeeToken
{
    constructor() BalancerV2FeeToken(
        "My Token", "MTKN",     // Name and Symbol
        1_000_000_000 ether,    // 1 billion supply
        address(this),          // Vault Address
        100, 200, 0)            // Fees: 2% buy 1% sell 0% P2P
    {
    }
}
```