// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on OpenZeppelin (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./UniswapV2FeeToken.sol";
import "./UniswapV2Interfaces.sol";

abstract contract UniswapV2AutoSwapToken is UniswapV2FeeToken
{
    uint256 public minTokensBeforeSwap;
    address public autoSwapRecipient;
    bool lastFeeActive;
    event Swap(uint amountSent);

    constructor(string memory name, string memory symbol,
        uint totalSupply_,
        uint buyFee, uint sellFee, uint p2pFee,
        address routerAddress,
        address baseTokenAddress,
        address autoSwapRecipient_,
        uint minTokensBeforeSwapPercent) UniswapV2FeeToken(name, symbol,
        totalSupply_,
        address(this),
        buyFee, sellFee, p2pFee,
        routerAddress,
        baseTokenAddress
        )
    {
        autoSwapRecipient = autoSwapRecipient_;
        setMinTokensBeforeSwapPercent(minTokensBeforeSwapPercent);
    }

    modifier lockTheSwap() {
        lastFeeActive = isFeeActive;
        _setFeeActive(false);
        _;
        _setFeeActive(lastFeeActive);
    }

    function swap() private lockTheSwap {
        uint totalSwap = balanceOf(address(this));
        if(minTokensBeforeSwap > totalSwap) return;
        if(totalSwap <= 0) return;

        address[] memory sellPath = new address[](2);
        sellPath[0] = address(this);
        sellPath[1] = address(baseToken);       

        _approve(address(this), address(router), totalSwap);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            totalSwap,
            0,
            sellPath,
            autoSwapRecipient,
            block.timestamp
        );
        
        emit Swap(totalSwap);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if(isFeeActive)
        {
            swap();
        }
        super._transfer(from, to, amount);
    }

    function setMinTokensBeforeSwapPercent(uint256 percentage) public onlyOwner {
        minTokensBeforeSwap = (totalSupply() * percentage) / (10**(feeDecimals + 2));
    }
}