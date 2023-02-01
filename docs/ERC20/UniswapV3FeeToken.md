# Solidity API

## UniswapV3FeeToken

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

### buyFeePercentage

```solidity
uint256 buyFeePercentage
```

### p2pFeePercentage

```solidity
uint256 p2pFeePercentage
```

### feeDecimals

```solidity
uint256 feeDecimals
```

### baseToken

```solidity
contract IERC20 baseToken
```

### pool1

```solidity
address pool1
```

### pool2

```solidity
address pool2
```

### pool3

```solidity
address pool3
```

### pool4

```solidity
address pool4
```

### nonfungiblePositionManager

```solidity
contract INonfungiblePositionManager nonfungiblePositionManager
```

### constructor

```solidity
constructor(string name, string symbol, uint256 totalSupply_, uint256 buyFeePercentage_, uint256 p2pFeePercentage_, address feeReceiver_, address baseTokenAddress, uint160 rate) internal
```

### _transfer

```solidity
function _transfer(address from, address to, uint256 amount) internal virtual
```

### setTaxless

```solidity
function setTaxless(address account, bool value) external
```

### setFeeActive

```solidity
function setFeeActive(bool value) public
```

### isPool

```solidity
function isPool(address _address) public view returns (bool)
```

### sqrt

```solidity
function sqrt(uint256 y) internal pure returns (uint256 z)
```

