// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on OpenZeppelin (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./UniswapV2Interfaces.sol";

abstract contract UniswapV2FeeToken is ERC20
{
    mapping(address => bool) public isTaxless;
    address public tokenVaultAddress;
    bool public isFeeActive;
    address public pair;
    uint[] public fees;
    uint public feeDecimals = 2;
    ISwapRouter router;
    IERC20 baseToken;


    constructor(string memory name, string memory symbol,
        uint totalSupply_,
        address tokenVaultAddress_,
        uint buyFee, uint sellFee, uint p2pFee,
        address routerAddress,
        address baseTokenAddress) ERC20(name, symbol, totalSupply_)
    {
        router = ISwapRouter(routerAddress);
        pair = ISwapFactory(router.factory()).createPair(address(this), baseTokenAddress);
        baseToken = IERC20(baseTokenAddress);
    
        tokenVaultAddress = tokenVaultAddress_;
        
        isTaxless[msg.sender] = true;
        isTaxless[address(this)] = true;
        isTaxless[tokenVaultAddress] = true;
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
        _balances[tokenVaultAddress] += feesCollected;

        emit Transfer(from, tokenVaultAddress, amount);
    
        super._transfer(from, to, amount);
    }

    function setTaxless(address account, bool value) external onlyOwner {
        isTaxless[account] = value;
    }

    function setFeeActive(bool value) public onlyOwner {
        isFeeActive = value;
    }
}