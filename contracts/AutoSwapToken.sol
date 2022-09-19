// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on OpenZeppelin (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./FeeToken.sol";

abstract contract AutoSwap is FeeToken
{
    constructor(string memory name, string memory symbol,
        uint buyFee, uint sellFee, uint p2pFee,
        address routerAddress,
        address baseTokenAddress,
        uint minTokensBeforeSwapPercent) FeeToken(name, symbol,
        address(this),
        buyFee, sellFee, p2pFee,
        routerAddress,
        baseTokenAddress
        )
    {
        ISwapRouter router = ISwapRouter(routerAddress);
        pair = ISwapFactory(router.factory()).createPair(address(this), baseTokenAddress);
    
        vaultAddress = _vaultAddress;
        
        isTaxless[msg.sender] = true;
        isTaxless[address(this)] = true;
        isTaxless[vaultAddress] = true;
        isTaxless[address(0)] = true;

        fees[0] = buyFee;
        fees[1] = sellFee;
        fees[2] = p2pFee;
        
        isFeeActive = true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        uint256 feesCollected;
        if (isFeeActive && !isTaxless[from] && !isTaxless[to]) {
            bool sell = to == pair;
            bool p2p = from != pair && to != pair;
            uint feeIndex = p2p ? 2 : sell ? 1 : 0;
            feesCollected = (amount * fees[feeIndex]) / (10**(feeDecimals + 2));
        }

        amount -= feesCollected;
        _balances[from] -= feesCollected;
        _balances[vaultAddress] += feesCollected;

        emit Transfer(from, vaultAddress, amount);
    
        super._transfer(from, to, amount);
    }

}