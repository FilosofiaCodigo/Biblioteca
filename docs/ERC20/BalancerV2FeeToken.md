# Solidity API

## BalancerV2FeeToken

You can use this contract launch your own token or to study the Balancer ecosystem

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

### balancerVault

```solidity
address balancerVault
```

Balancer vault constant address

### constructor

```solidity
constructor(string name, string symbol, uint256 totalSupply_, uint256 buyFeePercentage, uint256 sellFeePercentage, uint256 p2pFeePercentage, address feeReceiver_) internal
```

Contract constructor

_All percentage numbers are two digit decimals. For example 250 means 2.5%_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name | string | Token Name |
| symbol | string | Token Symbol |
| totalSupply_ | uint256 | Total supply, all supply will be sent to contract deployer |
| buyFeePercentage | uint256 | Percent of tokens that will be sent to the feeReciever when token is bought on Balancer |
| sellFeePercentage | uint256 | Percent of tokens that will be sent to the feeReciever when token is sold on Balancer |
| p2pFeePercentage | uint256 | Percent of tokens that will be sent to the feeReciever when token is transfered outside of Balancer |
| feeReceiver_ | address | Address that will recieve the fees taken every transaction |

### _transfer

```solidity
function _transfer(address from, address to, uint256 amount) internal virtual
```

This functions is inherited from OpenZeppelin and implements the transaction fee distribution

### setTaxless

```solidity
function setTaxless(address account, bool value) external
```

Set excemptions for transaction fee payments

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | Address that tax configuration will be affected |
| value | bool | If set to true the account will not pay transaction fees |

### setFeeActive

```solidity
function setFeeActive(bool value) public
```

Set excemptions for all transaction fee payments

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| value | bool | If set to true all transaction fees will not be charged |

