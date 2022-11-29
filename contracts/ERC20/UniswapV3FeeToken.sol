// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on OpenZeppelin (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./UniswapV3Interfaces.sol";

abstract contract UniswapV3FeeToken is ERC20
{
    mapping(address => bool) public isTaxless;
    address public tokenVaultAddress;
    bool public isFeeActive;
    uint buyFee;
    uint p2pFee;
    uint public feeDecimals = 2;
    IERC20 baseToken;
    address public pool1;
    address public pool2;
    address public pool3;
    address public pool4;

    INonfungiblePositionManager public nonfungiblePositionManager
        = INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    constructor(string memory name, string memory symbol,
        uint totalSupply_,
        address tokenVaultAddress_,
        uint buyFee_, uint p2pFee_,
        address baseTokenAddress,
        uint160 rate) ERC20(name, symbol, totalSupply_)
    {
        tokenVaultAddress = tokenVaultAddress_;
        baseToken = IERC20(baseTokenAddress);
        
        isTaxless[msg.sender] = true;
        isTaxless[address(this)] = true;
        isTaxless[tokenVaultAddress] = true;
        isTaxless[address(0)] = true;

        p2pFee = p2pFee_;
        buyFee = buyFee_;

        isTaxless[msg.sender] = true;
        isTaxless[address(this)] = true;
        isTaxless[tokenVaultAddress] = true;
        isTaxless[address(0)] = true;

        address token0;
        address token1;
        if(address(this) < baseTokenAddress)
        {
            token0 = address(this);
            token1 = baseTokenAddress;
        }else
        {
            token0 = baseTokenAddress;
            token1 = address(this);
        }

        uint160 RATE = rate;
        uint160 sqrtPriceX96;

        if(token0 == baseTokenAddress)
        {
            sqrtPriceX96 = uint160(sqrt(RATE)) * 2 ** 96;
        }else
        {
            sqrtPriceX96 = (2 ** 96) / uint160(sqrt(RATE));
        }

        pool1 = nonfungiblePositionManager.createAndInitializePoolIfNecessary(
            token0,
            token1,
            100/* fee */,
            sqrtPriceX96//Math.sqrt("1") * 2 ** 96
        );
        pool2 = nonfungiblePositionManager.createAndInitializePoolIfNecessary(
            token0,
            token1,
            500/* fee */,
            sqrtPriceX96//Math.sqrt("1") * 2 ** 96
        );
        pool3 = nonfungiblePositionManager.createAndInitializePoolIfNecessary(
            token0,
            token1,
            3000/* fee */,
            sqrtPriceX96//Math.sqrt("1") * 2 ** 96
        );
        pool4 = nonfungiblePositionManager.createAndInitializePoolIfNecessary(
            token0,
            token1,
            10000/* fee */,
            sqrtPriceX96//Math.sqrt("1") * 2 ** 96
        );

        isFeeActive = true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        uint256 feesCollected;
        if (!isTaxless[from] && !isTaxless[to]) {
            if(isPool(from))
            {
                feesCollected = (amount * buyFee) / (10**(feeDecimals + 2));
            }else if(!isPool(to))
            {
                feesCollected = (amount * p2pFee) / (10**(feeDecimals + 2));
            }
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

    function isPool(address _address) public view returns(bool)
    {
        return _address == pool1 || _address == pool2 || _address == pool3 || _address == pool4;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}