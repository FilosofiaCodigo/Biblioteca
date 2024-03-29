![](https://raw.githubusercontent.com/FilosofiaCodigo/Biblioteca/master/img/header.png)

<a href="https://www.alchemy.com/"><img onclick="logBadgeClick()" id="badge-button" style="width:240px;height:53px" src="https://static.alchemyapi.io/images/marketing/badgeLight.png" alt="Alchemy Supercharged"/></a>

![workflow](https://github.com/FilosofiaCodigo/Biblioteca/actions/workflows/unit-tests.yml/badge.svg)
[![Coverage Status](https://codecov.io/gh/FilosofiaCodigo/Biblioteca/graph/badge.svg)](https://codecov.io/gh/FilosofiaCodigo/Biblioteca)

Maximize interoperability for your smart contracts with the integrations library for decentralized protocols.

# 📜 Contracts

| Origin | Contract | Released | Unit Tests | Audit |
|-----|----------|-----------|------------|-------|
| <img src="https://raw.githubusercontent.com/FilosofiaCodigo/Biblioteca/master/img/icons/uniswap.png" width="50"/> | Uniswap V2 Fee Token | ✔ | ✔ | ❌ |
| <img src="https://raw.githubusercontent.com/FilosofiaCodigo/Biblioteca/master/img/icons/uniswap.png" width="50"/> | Uniswap V2 AutoSwap Token | ✔ | ✔ | ❌ |
| <img src="https://raw.githubusercontent.com/FilosofiaCodigo/Biblioteca/master/img/icons/balancer.png" width="50"/> | Balancer V2 Fee Token | ✔ | ✔ | ❌ |
| <img src="https://raw.githubusercontent.com/FilosofiaCodigo/Biblioteca/master/img/icons/uniswap.png" width="50"/> | Uniswap V3 Fee Token | ✔ | ✔ | ❌ |
| <img src="https://raw.githubusercontent.com/FilosofiaCodigo/Biblioteca/master/img/icons/openzeppelin.png" width="50"/> | OpenZeppelin NFT Collection | ✔ | ❌ | ❌ |
| <img src="https://raw.githubusercontent.com/FilosofiaCodigo/Biblioteca/master/img/icons/azuki.png" width="50"/> | Azuki NFT Collection | ✔ | ❌ | ❌ |
| | Aave Interface | ❌ | ❌ | ❌ |
| | Sudoswap Interface | ❌ | ❌ | ❌ |

# 🤔 Why Biblioteca?

Our ultimate goal is to simplify access to information and bring people together through web3. That's why we are so passionate about building a library that connects people and protocols. We encourage you to experiment with the library yourself by launching [the examples](#-erc20-tokens) or to study the underliying prococols by exploring the [Unit Tests](https://github.com/FilosofiaCodigo/Biblioteca/tree/master/test). If you would like to contribute, PRs are welcome!

# 🛡️ Running Tests & Coverage

```
npx hardhat test
npx hardhat coverage
```

# 🗎 Generate Documentation

```
npx hardhat docgen
```

# 📝 Take note

* This contracts are based on OpenZeppelin libraries but changed `private` variables to `internal` for flexibility
* All contracts are `Ownable`
* All percentage numbers are 2 digit decimals (e.g. 150 percent is 1.5%)

# ⚠️ Important!

Many libraries are not audited. Use at your own risk! Also, PRs and upstream changes very welcome.

# 🪙 ERC20 Tokens

## <img src="https://raw.githubusercontent.com/FilosofiaCodigo/Biblioteca/master/img/icons/uniswap.png" width="20" /> Uniswap V2 Fee Token

ERC20 token that takes fees on P2P, buy and sell on Uniswap V2 and transfer them to a Vault.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "biblioteca/contracts/ERC20/UniswapV2FeeToken.sol";

contract MyUniswapV2FeeToken is UniswapV2FeeToken
{
    constructor() UniswapV2FeeToken(
        "My Token", "MTKN",                         // Name and Symbol
        1_000_000_000 ether,                        // 1 billion supply
        100, 200, 50,                               // Fees: 1% buy 2% sell 0.5% P2P
        msg.sender,                                 // Fee Receiver
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, // Router Address: Uniswap V2
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48) // Base Token Address: USDC
    {
    }
}
```

See full [API documentation](https://github.com/FilosofiaCodigo/Biblioteca/blob/master/docs/ERC20/UniswapV2FeeToken.md).


## <img src="https://raw.githubusercontent.com/FilosofiaCodigo/Biblioteca/master/img/icons/uniswap.png" width="20"/> Uniswap V2 AutoSwap Token

ERC20 token that takes fees on P2P, buy and sell on Uniswap V2, converts them to Base Tokens and transfer them to a Vault.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "biblioteca/contracts/ERC20/UniswapV2AutoSwapToken.sol";

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
```

See full [API documentation](https://github.com/FilosofiaCodigo/Biblioteca/blob/master/docs/ERC20/UniswapV2AutoSwapToken.md).

## <img src="https://raw.githubusercontent.com/FilosofiaCodigo/Biblioteca/master/img/icons/balancer.png" width="20"/> Balancer V2 Fee Token

ERC20 token that takes fees on P2P, buy and sell on Balancer and transfer them to a Vault.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "biblioteca/contracts/ERC20/BalancerV2FeeToken.sol";

contract MyBalancerFeeToken is BalancerV2FeeToken
{
    constructor() BalancerV2FeeToken(
        "My Token", "MTKN",     // Name and Symbol
        1_000_000_000 ether,    // 1 billion supply
        100, 200, 50,           // Fees: 2% buy 1% sell 0.5% P2P
        msg.sender)             // Fee Receiver
    {
    }
}
```

See full [API documentation](https://github.com/FilosofiaCodigo/Biblioteca/blob/master/docs/ERC20/BalancerV2FeeToken.md).

## <img src="https://raw.githubusercontent.com/FilosofiaCodigo/Biblioteca/master/img/icons/uniswap.png" width="20"/> Uniswap V3 Fee Token

ERC20 token that takes fees on P2P, and buy on Uniswap V3 and transfer them to a Vault.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "biblioteca/contracts/ERC20/UniswapV3FeeToken.sol";

contract MyUniswapV3FeeToken is UniswapV3FeeToken
{
    constructor() UniswapV3FeeToken(
        "My Token", "MTKN",                         // Name and Symbol
        1_000_000_000 ether,                        // 1 billion supply
        100, 200,                                   // Fees: 1% buy 2% P2P
        msg.sender,                                 // Vault Address
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, // Base token: WETH
        1000)                                       // Initial rate: 1 WETH = 1000 tokens
    {
    }
}
```

See full [API documentation](https://github.com/FilosofiaCodigo/Biblioteca/blob/master/docs/ERC20/UniswapV3FeeToken.md).

# 🖼️ NFT Collections

## <img src="https://raw.githubusercontent.com/FilosofiaCodigo/Biblioteca/master/img/icons/openzeppelin.png" width="20"/> OpenZeppelin NFT Collection

NFT collection with a mint price and max supply. Uses OpenZeppelin library wich is more adopted and save transfer gas fees compared to Azuki's ERC721a.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "biblioteca/contracts//ERC721/OpenZeppelinNFTCollection.sol";

contract MyOpenZeppelinNFTCollection is OpenZeppelinNFTCollection
{
    constructor() OpenZeppelinNFTCollection(
        "My NFT Collection", "MNFT",    // Name and Symbol
        "https://raw.githubusercontent.com/FilosofiaCodigo/nft-collection-api/master/metadata/",    // Base Metadata URI
        10_000,         // 10,000 max supply
        0.01 ether)     // 0.01 eth mint price
    {
    }
}
```

## <img src="https://raw.githubusercontent.com/FilosofiaCodigo/Biblioteca/master/img/icons/azuki.png" width="20"/> Azuki ERC721a NFT Collection

NFT collection with a mint price and max supply. Uses ERC721a library wich is more newer and save batch mint gas fees compared to OpenZeppelin's ERC721 implementation.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "biblioteca/contracts//ERC721/ERC721aCollection.sol";

contract MyERC721aCollection is ERC721aCollection
{
    constructor() ERC721aCollection(
        "My NFT Collection", "MNFT",    // Name and Symbol
        "https://raw.githubusercontent.com/FilosofiaCodigo/nft-collection-api/master/metadata/",    // Base Metadata URI
        10_000,         // 10,000 max supply
        0.01 ether)     // 0.01 eth mint price
    {
    }
}
```
