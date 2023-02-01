# Solidity API

## UniswapV2AutoSwapToken

### minTokensBeforeSwap

```solidity
uint256 minTokensBeforeSwap
```

### autoSwapReciever

```solidity
address autoSwapReciever
```

### lastFeeActive

```solidity
bool lastFeeActive
```

### Swap

```solidity
event Swap(uint256 amountSent)
```

### constructor

```solidity
constructor(string name, string symbol, uint256 totalSupply_, uint256 buyFeePercentage, uint256 sellFeePercentage, uint256 p2pFeePercentage, address autoSwapReciever_, address routerAddress, address baseTokenAddress, uint256 minTokensBeforeSwapPercent) internal
```

### lockTheSwap

```solidity
modifier lockTheSwap()
```

### _transfer

```solidity
function _transfer(address from, address to, uint256 amount) internal virtual
```

### setMinTokensBeforeSwapPercent

```solidity
function setMinTokensBeforeSwapPercent(uint256 percentage) public
```

