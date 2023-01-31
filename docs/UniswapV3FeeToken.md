# UniswapV3FeeToken

Token that main liquidity will be added to a Uniswap V3. Takes fees on transfer and stores it in a `Fee Receiver Address`.

## Technical contract overview

The UniswapV3FeeToken collects fees depending on the transaction type: buy or P2P (peer to peer). Fees are sent to a `feeReceiver`. In the constructor a `baseToken` is set in order to create a uniswap `pair`. The `pair` helps us detecting wheter a transaction is Sell, Buy or P2P. Keep in mind that fees on sell can't be added due to Uniswap V3 technical limitation.

## Constructing a UniswapV2FeeToken contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "biblioteca/contracts/ERC20/UniswapV3FeeToken.sol";

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
```

## API

### **constructor**(string memory name, string memory symbol, uint totalSupply\_, address feeReceiver\_, uint buyFeePercentage, uint sellFeePercentage, uint p2pFeePercentage, address routerAddress, address baseTokenAddress)

Constructor parameters:
* **name**: Token name
* **symbol**: Token symbol
* **totalSupply**: Initial supply in wei
* **feeReceiver**: Address that will receive fees collected
* **buyFeePercentage**: Fee percentange collected when tokens are sent from the pair
* **sellFeePercentage**: Fee percentange collected when the tokens are sent to the pair
* **p2pFeePercentage**: Fee percentange collected when tokens are not sent from nor to the pair
* **routerAddress**: Router address where the main liquidity will be added
* **baseTokenAddress**: Base token that will be paired with the token when liquidity is added

```solidity
constructor() UniswapV2FeeToken(
  "My Token", "MTKN",                         // Name and Symbol
  1_000_000_000 ether,                        // 1 billion supply
  address(this),                              // Vault Address
  100, 200, 0,                                // Fees: 2% buy 1% sell 0% P2P
  0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, // Router Address
  0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48) // Base Token Address
{
}
```

### **\_setTaxless**(address account, bool isTaxless\_) internal

Add a Fee exempt address.

```solidity
function setTaxless(address account, bool isTaxless_) internal onlyOwner
{
  _setTaxless(account, isTaxless_);
}
```

### **\_setFeeReceiver**(address feeReceiver\_) internal

Address that will receive the token Fees collected.

```solidity
function setFeeReceiver(address feeReceiver_) internal onlyOwner
{
  _setFeeReceiver(feeReceiver_);
}
```

### **\_setFeeActive**(bool isFeeActive\_) internal

Set wheter or not fees are being collected.

```solidity
function setFeeActive(bool isFeeActive_) internal onlyOwner
{
  _setFeeActive(isFeeActive_);
}
```

### **\_setPair**(address router_, address baseToken\_) internal

Change the main pair address by passing the router and the base token as parameter. Creates a new pair in case it wasn't created. After this function is called the fees will be collected in this pair.

```solidity
function setPair(address router_, address baseToken_) internal onlyOwner
{
  _setPair(router_, baseToken_);
}
```

### **\_setFees**(uint buyFeePercentage, uint sellFeePercentage, uint p2pFeePercentage) internal

Buy and sell fees are collected when interacting with the pair. P2P fees are collected when interacting with other address than the pair.

```solidity
function _setFees(uint buyFeePercentage, uint sellFeePercentage, uint p2pFeePercentage) internal onlyOwner
{
  _setFees(buyFeePercentage, sellFeePercentage, p2pFeePercentage);
}
```