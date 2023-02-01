// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on OpenZeppelin (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./interfaces/BalancerInterfaces.sol";

/// @title ERC20 token that takes fees on P2P, buy and sell on Balancer and transfer them to a Vault.
/// @author Filosofía Codigo
/// @notice You can use this contract launch your own token or to study the Balancer ecosystem
/// @dev Based on top OpenZeppelin contracts but changed balances from private to internal for flexibility
/// @custom:experimental This is an experimental contract.
abstract contract BalancerV2FeeToken is ERC20
{
    /// @notice List of address that won't pay transaction fees
    mapping(address => bool) public isTaxless;
    /// @notice Address that will recieve fees taken from each transaction
    address public feeReceiver;
    /// @notice If set to true, no fees will be taken on any transaction
    bool public isFeeActive;
    /// @notice Array that defines the transactions fees. Index 0 is buy fee, 1 is sell fee and 2 is peer to peer fee
    uint[] public fees;
    /// @notice Number if fee decimals. Default is 2 so for example 250 means 2.5% in percentage numbers
    uint public feeDecimals = 2;
    /// @notice Balancer vault constant address
    address public balancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    /// @notice Contract constructor
    /// @dev All percentage numbers are two digit decimals. For example 250 means 2.5%
    /// @param name Token Name
    /// @param symbol Token Symbol
    /// @param totalSupply_ Total supply, all supply will be sent to contract deployer
    /// @param buyFeePercentage Percent of tokens that will be sent to the feeReciever when token is bought on Balancer
    /// @param sellFeePercentage Percent of tokens that will be sent to the feeReciever when token is sold on Balancer
    /// @param p2pFeePercentage Percent of tokens that will be sent to the feeReciever when token is transfered outside of Balancer
    /// @param feeReceiver_ Address that will recieve the fees taken every transaction
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

    /// @notice This functions is inherited from OpenZeppelin and implements the transaction fee distribution
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

    /// @notice Set excemptions for transaction fee payments
    /// @param account Address that tax configuration will be affected
    /// @param value If set to true the account will not pay transaction fees
    /// @custom:ownable This function can only be executed by the contract owner.
    function setTaxless(address account, bool value) external onlyOwner {
        isTaxless[account] = value;
    }

    /// @notice Set excemptions for all transaction fee payments
    /// @param value If set to true all transaction fees will not be charged
    /// @custom:ownable This function can only be executed by the contract owner.
    function setFeeActive(bool value) public onlyOwner {
        isFeeActive = value;
    }
}