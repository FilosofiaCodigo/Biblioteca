# Solidity API

## UniswapV2FeeToken

You can use this contract launch your own token or to study the Uniswap V2 ecosystem.

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

### fees

```solidity
uint256[] fees
```

Array that defines the transactions fees. Index 0 is buy fee, 1 is sell fee and 2 is peer to peer fee

### feeDecimals

```solidity
uint256 feeDecimals
```

Number if fee decimals. Default is 2 so for example 250 means 2.5% in percentage numbers

### pair

```solidity
address pair
```

Uniswap V2 Pair formed by this token and the base token

### router

```solidity
contract ISwapRouter router
```

Uniswap V2 Router address

### baseToken

```solidity
contract IERC20 baseToken
```

Token that will be paired with this token when liquidity is added to the DEX

### constructor

```solidity
constructor(string name, string symbol, uint256 totalSupply_, uint256 buyFeePercentage, uint256 sellFeePercentage, uint256 p2pFeePercentage, address feeReceiver_, address routerAddress, address baseTokenAddress) internal
```

Contract constructor

_All percentage numbers are two digit decimals. For example 250 means 2.5%_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name | string | Token Name |
| symbol | string | Token Symbol |
| totalSupply_ | uint256 | Total supply, all supply will be sent to contract deployer |
| buyFeePercentage | uint256 | Percent of tokens that will be sent to the feeReciever when token is bought on Uniswap V2 |
| sellFeePercentage | uint256 | Percent of tokens that will be sent to the feeReciever when token is sold on Uniswap V2 |
| p2pFeePercentage | uint256 | Percent of tokens that will be sent to the feeReciever when token is transfered outside of Uniswap V2 |
| feeReceiver_ | address | Address that will recieve the fees taken every transaction |
| routerAddress | address | You can support such DEXes by setting the router address in this param. Many projects such as Pancakeswap, Sushiswap or Quickswap are compatible with Uniswap V2 |
| baseTokenAddress | address | Token address that this will be paired with on the DEX. Fees will be sent to the autoSwapReciever in the base token denomination |

### _transfer

```solidity
function _transfer(address from, address to, uint256 amount) internal virtual
```

This functions is inherited from OpenZeppelin and implements the transaction fee distribution

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
function _setFees(uint256 buyFeePercentage, uint256 sellFeePercentage, uint256 p2pFeePercentage) internal
```

The fee percentage for buy, sell and peer to peer

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| buyFeePercentage | uint256 | New buy percentage fee |
| sellFeePercentage | uint256 | New sell percentage fee |
| p2pFeePercentage | uint256 | New peer to peer percentage fee |

### _setPair

```solidity
function _setPair(address router_, address baseToken_) internal
```

Changes the router, base token and pair address in case the the liquidity wants to be moved to other DEX or base token

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| router_ | address | New router that will be updated |
| baseToken_ | address | New base token that will be used |

