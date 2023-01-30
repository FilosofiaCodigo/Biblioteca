// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on OpenZeppelin (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./BalancerInterfaces.sol";

abstract contract BalancerV2FeeToken is ERC20
{
    mapping(address => bool) public isTaxless;
    address public tokenVaultAddress;
    bool public isFeeActive;
    uint[] public fees;
    uint public feeDecimals = 2;
    address public balancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    constructor(string memory name, string memory symbol,
        uint totalSupply_,
        address tokenVaultAddress_,
        uint buyFee, uint sellFee, uint p2pFee)
        ERC20(name, symbol, totalSupply_)
    {
        tokenVaultAddress = tokenVaultAddress_;
        
        isTaxless[msg.sender] = true;
        isTaxless[address(this)] = true;
        isTaxless[tokenVaultAddress] = true;
        isTaxless[address(0)] = true;

        fees.push(buyFee);
        fees.push(sellFee);
        fees.push(p2pFee);
        
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