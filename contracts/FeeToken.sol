// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on OpenZeppelin (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./ERC20.sol";

interface ISwapRouter {
    function factory() external pure returns (address);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract FeeToken is ERC20
{
    mapping(address => bool) public isTaxless;
    address public vaultAddress;
    bool public isFeeActive;
    address public pair;
    uint[] public fees;
    uint public feeDecimals = 2;

    constructor(string memory name, string memory symbol,
        address _vaultAddress,
        uint buyFee, uint sellFee, uint p2pFee,
        address routerAddress,
        address baseTokenAddress) ERC20(name, symbol)
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

    function setTaxless(address account, bool value) external onlyOwner {
        isTaxless[account] = value;
    }

    function setFeeActive(bool value) external onlyOwner {
        isFeeActive = value;
    }
}