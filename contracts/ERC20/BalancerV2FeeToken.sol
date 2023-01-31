// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on OpenZeppelin (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./interfaces/BalancerInterfaces.sol";

abstract contract BalancerV2FeeToken is ERC20
{
    mapping(address => bool) public isTaxless;
    address public feeReceiver;
    bool public isFeeActive;
    uint[] public fees;
    uint public feeDecimals = 2;
    address public balancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    constructor(string memory name, string memory symbol,
        uint totalSupply_,
        uint buyFeePercentage, uint sellFeePercentage, uint p2pFeePercentage,
        address feeReceiver_)
        ERC20(name, symbol, totalSupply_)
    {
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
    ) internal virtual override {
        uint256 feesCollected;
        if (isFeeActive && !isTaxless[from] && !isTaxless[to]) {
            bool sell = to == balancerVault;
            bool p2p = from != balancerVault && to != balancerVault;
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

    function setTaxless(address account, bool value) external onlyOwner {
        isTaxless[account] = value;
    }

    function setFeeActive(bool value) public onlyOwner {
        isFeeActive = value;
    }
}