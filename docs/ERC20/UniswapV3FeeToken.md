# Solidity API

## UniswapV3FeeToken

You can use this contract launch your own token or to study the Uniswap V3 ecosystem.

_Based on top OpenZeppelin contracts but changed balances from private to internal for flexibility_

### isTaxless

```solidity
mapping(address => bool) isTaxless
```

List of address that won't pay transaction fees

### feeReceiver

```solidity
address feeReceiver
```

Address that will recieve fees taken from each transaction

### isFeeActive

```solidity
bool isFeeActive
```

If set to true, no fees will be taken on any transaction

### buyFeePercentage

```solidity
uint256 buyFeePercentage
```

Fee percentage token when the token is bought on the Uniswap V3 Pair

### p2pFeePercentage

```solidity
uint256 p2pFeePercentage
```

Fee percentage token when the token is transfered to other address outside of the V3 Pair

### feeDecimals

```solidity
uint256 feeDecimals
```

Number if fee decimals. Default is 2 so for example 250 means 2.5% in percentage numbers

### baseToken

```solidity
contract IERC20 baseToken
```

Token that will be paired with this token when liquidity is added to the DEX

### pool1

```solidity
address pool1
```

_0.01% uniswap v3 pool used to check if the token is being bought or sold_

### pool2

```solidity
address pool2
```

_0.05% uniswap v3 pool used to check if the token is being bought or sold_

### pool3

```solidity
address pool3
```

_0.3% uniswap v3 pool used to check if the token is being bought or sold_

### pool4

```solidity
address pool4
```

_1% uniswap v3 pool used to check if the token is being bought or sold_

### nonfungiblePositionManager

```solidity
contract INonfungiblePositionManager nonfungiblePositionManager
```

Uniswap V3 Position Manager used to gather the pool addresses

### constructor

```solidity
constructor(string name, string symbol, uint256 totalSupply_, uint256 buyFeePercentage_, uint256 p2pFeePercentage_, address feeReceiver_, address baseTokenAddress, uint160 rate) internal
```

Contract constructor

_All percentage numbers are two digit decimals. For example 250 means 2.5%_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name | string | Token Name |
| symbol | string | Token Symbol |
| totalSupply_ | uint256 | Total supply, all supply will be sent to contract deployer |
| buyFeePercentage_ | uint256 | Percent of tokens that will be sent to the feeReciever when token is bought on Uniswap V3 |
| p2pFeePercentage_ | uint256 | Percent of tokens that will be sent to the feeReciever when token is transfered outside of Uniswap V3 |
| feeReceiver_ | address | Address that will recieve the fees taken every transaction |
| baseTokenAddress | address | Token address that this will be paired with on the DEX. Fees will be sent to the autoSwapReciever in the base token denomination |
| rate | uint160 | Initial token value in the form of 1 base token = `rate` tokens |

### _transfer

```solidity
function _transfer(address from, address to, uint256 amount) internal virtual
```

This functions is inherited from OpenZeppelin and implements the transaction fee distribution

### _isPool

```solidity
function _isPool(address _address) internal view returns (bool)
```

_Checks if an address is part of the Uniswap V3 pools. This is for internal use._

### sqrt

```solidity
function sqrt(uint256 y) internal pure returns (uint256 z)
```

_Square root function for internal use_

### _setTaxless

```solidity
function _setTaxless(address account, bool isTaxless_) internal
```

Set excemptions for transaction fee payments

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | Address that tax configuration will be affected |
| isTaxless_ | bool | If set to true the account will not pay transaction fees |

### _setFeeReceiver

```solidity
function _setFeeReceiver(address feeReceiver_) internal
```

Changes the address that will recieve fees

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| feeReceiver_ | address | If set to true the account will not pay transaction fees |

### _setFeeActive

```solidity
function _setFeeActive(bool isFeeActive_) internal
```

Changes the address that will recieve fees

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| isFeeActive_ | bool | If set to true all transaction fees will not be charged |

### _setFees

```solidity
function _setFees(uint256 buyFeePercentage_, uint256 p2pFeePercentage_) internal
```

The fee percentage for buy, sell and peer to peer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| buyFeePercentage_ | uint256 | New buy percentage fee |
| p2pFeePercentage_ | uint256 | New peer to peer percentage fee |

