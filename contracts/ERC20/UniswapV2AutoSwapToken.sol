// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on OpenZeppelin (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./UniswapV2FeeToken.sol";
import "./interfaces/UniswapV2Interfaces.sol";

/// @title ERC20 token that takes fees on P2P, buy and sell on a Uniswap V2 contract and then transfers the collected fees to a autoSwapReciever address in the form of base tokens.
/// @author Filosofía Codigo
/// @notice You can use this contract launch your own token or to study the Uniswap V2 ecosystem.
/// @dev Based on top OpenZeppelin contracts but changed balances from private to internal for flexibility
abstract contract UniswapV2AutoSwapToken is UniswapV2FeeToken
{
    /// @notice Percentage of total supply that have to be accumulated as fees to trigger the autoswap and send the fees to the autoSwapReciever
    uint256 public minTokensBeforeSwap;
    /// @notice Address that will recieve fees on base token denomination
    address public autoSwapReciever;
    /// @dev Internal flag that prevents infinite recursion during the autoswap
    bool lastFeeActive;
    /// @dev Event emited during the autoswap
    event Swap(uint amountSent);

    /// @notice Contract constructor
    /// @dev All percentage numbers are two digit decimals. For example 250 means 2.5%
    /// @param name Token Name
    /// @param symbol Token Symbol
    /// @param totalSupply_ Total supply, all supply will be sent to contract deployer
    /// @param buyFeePercentage Percent of tokens that will be sent to the feeReciever when token is bought on Uniswap V2
    /// @param sellFeePercentage Percent of tokens that will be sent to the feeReciever when token is sold on Uniswap V2
    /// @param p2pFeePercentage Percent of tokens that will be sent to the feeReciever when token is transfered outside of Uniswap V2
    /// @param autoSwapReciever_ Address that will recieve the fees taken every transaction
    /// @param routerAddress You can support such DEXes by setting the router address in this param. Many projects such as Pancakeswap, Sushiswap or Quickswap are compatible with Uniswap V2
    /// @param baseTokenAddress Token address that this will be paired with on the DEX. Fees will be sent to the autoSwapReciever in the base token denomination
    /// @param minTokensBeforeSwapPercent Percentage of total supply that have to be accumulated as fees to trigger the autoswap and send the fees to the autoSwapReciever
    constructor(string memory name, string memory symbol,
        uint totalSupply_,
        uint buyFeePercentage, uint sellFeePercentage, uint p2pFeePercentage,
        address autoSwapReciever_,
        address routerAddress,
        address baseTokenAddress,
        uint minTokensBeforeSwapPercent) UniswapV2FeeToken(name, symbol,
        totalSupply_,
        buyFeePercentage, sellFeePercentage, p2pFeePercentage,
        address(this),
        routerAddress,
        baseTokenAddress
        )
    {
        autoSwapReciever = autoSwapReciever_;
        setMinTokensBeforeSwapPercent(minTokensBeforeSwapPercent);
    }

    /// @dev internal modifier to prevent infinite recursion while executing the autoswap
    modifier lockTheSwap() {
        lastFeeActive = isFeeActive;
        _setFeeActive(false);
        _;
        _setFeeActive(lastFeeActive);
    }

    /// @dev Swaps all the fees collected to base tokens and send it to the autoSwapReciever
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
            autoSwapReciever,
            block.timestamp
        );
        
        emit Swap(totalSwap);
    }

    /// @notice This functions is inherited from OpenZeppelin and UniswapV2FeeToken that runs the autoswap in case it's ready to be executed
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

    /// @notice Change the minimum ammount of fees collected to trigger the autoswap
    /// @param percentage Percentage of total supply that have to be accumulated as fees to trigger the autoswap and send the fees to the autoSwapReciever
    function setMinTokensBeforeSwapPercent(uint256 percentage) public onlyOwner {
        minTokensBeforeSwap = (totalSupply() * percentage) / (10**(feeDecimals + 2));
    }
}