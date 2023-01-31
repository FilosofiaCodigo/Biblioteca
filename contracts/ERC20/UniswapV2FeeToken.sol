// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on OpenZeppelin (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./interfaces/UniswapV2Interfaces.sol";

abstract contract UniswapV2FeeToken is ERC20
{
    mapping(address => bool) public isTaxless;
    address public feeReceiver;
    bool public isFeeActive;
    uint[] public fees;
    uint public feeDecimals = 2;
    address public pair;
    ISwapRouter router;
    IERC20 baseToken;


    constructor(string memory name, string memory symbol,
        uint totalSupply_,
        uint buyFeePercentage, uint sellFeePercentage, uint p2pFeePercentage,
        address feeReceiver_,
        address routerAddress,
        address baseTokenAddress) ERC20(name, symbol, totalSupply_)
    {
        router = ISwapRouter(routerAddress);
        pair = ISwapFactory(router.factory()).createPair(address(this), baseTokenAddress);
        baseToken = IERC20(baseTokenAddress);
    
        feeReceiver = feeReceiver_;
        
        isTaxless[msg.sender] = true;
        isTaxless[address(this)] = true;
        isTaxless[feeReceiver] = true;
        isTaxless[address(0)] = true;

        fees.push(buyFeePercentage);
        fees.push(sellFeePercentage);
        fees.push(p2pFeePercentage);
        
        isFeeActive = true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override
    {
        uint256 feesCollected;
        if (isFeeActive && !isTaxless[from] && !isTaxless[to]) {
            bool sell = to == pair;
            bool p2p = from != pair && to != pair;
            uint feeIndex = 0;
            if(p2p)
                feeIndex = 2;
            else if(sell)
                feeIndex = 1;
            feesCollected = (amount * fees[feeIndex]) / (10**(feeDecimals + 2));
        }

        amount -= feesCollected;
        _balances[from] -= feesCollected;
        _balances[feeReceiver] += feesCollected;

        emit Transfer(from, feeReceiver, amount);
    
        super._transfer(from, to, amount);
    }

    function _setTaxless(address account, bool isTaxless_) internal
    {
        isTaxless[account] = isTaxless_;
    }

    function _setFeeReceiver(address feeReceiver_) internal
    {
        feeReceiver = feeReceiver_;
    }

    function _setFeeActive(bool isFeeActive_) internal
    {
        isFeeActive = isFeeActive_;
    }

    function _setPair(address router_, address baseToken_) internal
    {
        router = ISwapRouter(router_);
        baseToken = IERC20(baseToken_);
        pair = ISwapFactory(router.factory()).getPair(address(this), address(baseToken));
        if(pair == address(0))
        {
            pair = ISwapFactory(router.factory()).createPair(address(this), address(baseToken));
        }
    }

    function _setFees(uint buyFeePercentage, uint sellFeePercentage, uint p2pFeePercentage) internal
    {
        fees[0] = buyFeePercentage;
        fees[1] = sellFeePercentage;
        fees[2] = p2pFeePercentage;
    }
}