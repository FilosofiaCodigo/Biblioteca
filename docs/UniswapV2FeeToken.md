# UniswapV2FeeToken

## Technical contract overview

The UniswapV2FeeToken is a type of token very common in DeFi. It collects fees depending on the transaction type (Sell, Buy or P2P peer to peer). Fees are sent to a `feeReceiverAddress`. In the constructor a `router` and `baseToken` is set in order to create a uniswap `pair`. The `pair` helps us detecting wheter a transaction is Sell, Buy or P2P.

## Constructing a UniswapV2FeeToken contract

ToDo.

## API

* **_setTaxless**(address account, bool isTaxless_) internal
  * Add a Fee exempt address.
* **_setFeeReceiverAddress**(address feeReceiverAddress_) internal
  * Address that will receive the token Fees collected.
* **_setFeeActive**(bool isFeeActive_) internal
  * Set wheter or not fees are being collected.
* **_setPair**(address router_, address baseToken_)** internal
  * Change the main pair address by passing the router and the base token as parameter. Creates a new pair in case it wasn't created. After this function is called the fees will be collected in this pair.
* **_setFees**(uint buyFeePercentage, uint sellFeePercentage, uint p2pFeePercentage)** internal
  * Buy and sell fees are collected when interacting with the pair. P2P fees are collected when interacting with other address than the pair.