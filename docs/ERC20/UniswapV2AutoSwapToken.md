# Solidity API

## UniswapV2AutoSwapToken

You can use this contract launch your own token or to study the Uniswap V2 ecosystem.

_Based on top OpenZeppelin contracts but changed balances from private to internal for flexibility_

### minTokensBeforeSwap

```solidity
uint256 minTokensBeforeSwap
```

Percentage of total supply that have to be accumulated as fees to trigger the autoswap and send the fees to the autoSwapReciever

### autoSwapReciever

```solidity
address autoSwapReciever
```

Address that will recieve fees on base token denomination

### lastFeeActive

```solidity
bool lastFeeActive
```

_Internal flag that prevents infinite recursion during the autoswap_

### Swap

```solidity
event Swap(uint256 amountSent)
```

_Event emited during the autoswap_

### constructor

```solidity
constructor(string name, string symbol, uint256 totalSupply_, uint256 buyFeePercentage, uint256 sellFeePercentage, uint256 p2pFeePercentage, address autoSwapReciever_, address routerAddress, address baseTokenAddress, uint256 minTokensBeforeSwapPercent) internal
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
| autoSwapReciever_ | address | Address that will recieve the fees taken every transaction |
| routerAddress | address | You can support such DEXes by setting the router address in this param. Many projects such as Pancakeswap, Sushiswap or Quickswap are compatible with Uniswap V2 |
| baseTokenAddress | address | Token address that this will be paired with on the DEX. Fees will be sent to the autoSwapReciever in the base token denomination |
| minTokensBeforeSwapPercent | uint256 | Percentage of total supply that have to be accumulated as fees to trigger the autoswap and send the fees to the autoSwapReciever |

### lockTheSwap

```solidity
modifier lockTheSwap()
```

_internal modifier to prevent infinite recursion while executing the autoswap_

### _transfer

```solidity
function _transfer(address from, address to, uint256 amount) internal virtual
```

This functions is inherited from OpenZeppelin and UniswapV2FeeToken that runs the autoswap in case it's ready to be executed

### setMinTokensBeforeSwapPercent

```solidity
function setMinTokensBeforeSwapPercent(uint256 percentage) public
```

Change the minimum ammount of fees collected to trigger the autoswap

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| percentage | uint256 | Percentage of total supply that have to be accumulated as fees to trigger the autoswap and send the fees to the autoSwapReciever |

