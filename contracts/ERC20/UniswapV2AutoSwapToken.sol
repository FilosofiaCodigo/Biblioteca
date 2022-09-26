// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on OpenZeppelin (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./UniswapV2FeeToken.sol";
import "./UniswapV2Interfaces.sol";

abstract contract UniswapV2AutoSwapToken is UniswapV2FeeToken
{
    uint256 public minTokensBeforeSwap;
    bool lastFeeActive;
    event Swap(uint amountSent);
    address autoSwapRecipient;

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

        address[] memory sellPath = new address[](2);
        sellPath[0] = address(this);
        sellPath[1] = address(baseToken);       

        _approve(address(this), address(router), totalSwap);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            totalSwap,
            0,
            sellPath,
            address(this),
            block.timestamp
        );

        if(address(this).balance > 0) sendViaCall(payable(autoSwapRecipient), address(this).balance);
        
        emit Swap(totalSwap);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._transfer(from, to, amount);
    }

    function setMinTokensBeforeSwapPercent(uint256 percentage) public onlyOwner {
        minTokensBeforeSwap = (totalSupply() * percentage) / (10**(feeDecimals + 2));
    }

    function sendViaCall(address payable _to, uint amount) private {
        (bool sent, bytes memory data) = _to.call{value: amount}("");
        data;
        require(sent, "Failed to send Ether");
    }
}