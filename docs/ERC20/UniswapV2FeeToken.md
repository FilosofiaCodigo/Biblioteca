# Solidity API

## UniswapV2FeeToken

### isTaxless

```solidity
mapping(address => bool) isTaxless
```

### feeReceiver

```solidity
address feeReceiver
```

### isFeeActive

```solidity
bool isFeeActive
```

### fees

```solidity
uint256[] fees
```

### feeDecimals

```solidity
uint256 feeDecimals
```

### pair

```solidity
address pair
```

### router

```solidity
contract ISwapRouter router
```

### baseToken

```solidity
contract IERC20 baseToken
```

### constructor

```solidity
constructor(string name, string symbol, uint256 totalSupply_, uint256 buyFeePercentage, uint256 sellFeePercentage, uint256 p2pFeePercentage, address feeReceiver_, address routerAddress, address baseTokenAddress) internal
```

### _transfer

```solidity
function _transfer(address from, address to, uint256 amount) internal virtual
```

### _setTaxless

```solidity
function _setTaxless(address account, bool isTaxless_) internal
```

### _setFeeReceiver

```solidity
function _setFeeReceiver(address feeReceiver_) internal
```

### _setFeeActive

```solidity
function _setFeeActive(bool isFeeActive_) internal
```

### _setPair

```solidity
function _setPair(address router_, address baseToken_) internal
```

### _setFees

```solidity
function _setFees(uint256 buyFeePercentage, uint256 sellFeePercentage, uint256 p2pFeePercentage) internal
```

