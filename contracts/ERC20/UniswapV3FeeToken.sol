// SPDX-License-Identifier: MIT
// Filosofía Código Contracts based on OpenZeppelin (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./interfaces/UniswapV3Interfaces.sol";

/// @title ERC20 token that takes fees on buy on Uniswap V3 and on peer to peero and transfer them to the feeReceiver.
/// @author Filosofía Codigo
/// @notice You can use this contract launch your own token or to study the Uniswap V3 ecosystem.
/// @dev Based on top OpenZeppelin contracts but changed balances from private to internal for flexibility
abstract contract UniswapV3FeeToken is ERC20
{
    /// @notice List of address that won't pay transaction fees
    mapping(address => bool) public isTaxless;
    /// @notice Address that will recieve fees taken from each transaction
    address public feeReceiver;
    /// @notice If set to true, no fees will be taken on any transaction
    bool public isFeeActive;
    /// @notice Fee percentage token when the token is bought on the Uniswap V3 Pair
    uint buyFeePercentage;
    /// @notice Fee percentage token when the token is transfered to other address outside of the V3 Pair
    uint p2pFeePercentage;
    /// @notice Number if fee decimals. Default is 2 so for example 250 means 2.5% in percentage numbers
    uint public feeDecimals = 2;
    /// @notice Token that will be paired with this token when liquidity is added to the DEX
    IERC20 baseToken;
    /// @dev 0.01% uniswap v3 pool used to check if the token is being bought or sold
    address public pool1;
    /// @dev 0.05% uniswap v3 pool used to check if the token is being bought or sold
    address public pool2;
    /// @dev 0.3% uniswap v3 pool used to check if the token is being bought or sold
    address public pool3;
    /// @dev 1% uniswap v3 pool used to check if the token is being bought or sold
    address public pool4;

    /// @notice Uniswap V3 Position Manager used to gather the pool addresses
    INonfungiblePositionManager public nonfungiblePositionManager
        = INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    /// @notice Contract constructor
    /// @dev All percentage numbers are two digit decimals. For example 250 means 2.5%
    /// @param name Token Name
    /// @param symbol Token Symbol
    /// @param totalSupply_ Total supply, all supply will be sent to contract deployer
    /// @param buyFeePercentage_ Percent of tokens that will be sent to the feeReciever when token is bought on Uniswap V3
    /// @param p2pFeePercentage_ Percent of tokens that will be sent to the feeReciever when token is transfered outside of Uniswap V3
    /// @param feeReceiver_ Address that will recieve the fees taken every transaction
    /// @param baseTokenAddress Token address that this will be paired with on the DEX. Fees will be sent to the autoSwapReciever in the base token denomination
    /// @param rate Initial token value in the form of 1 base token = `rate` tokens
    constructor(string memory name, string memory symbol,
        uint totalSupply_,
        uint buyFeePercentage_, uint p2pFeePercentage_,
        address feeReceiver_,
        address baseTokenAddress,
        uint160 rate) ERC20(name, symbol, totalSupply_)
    {
        feeReceiver = feeReceiver_;
        baseToken = IERC20(baseTokenAddress);
        
        isTaxless[msg.sender] = true;
        isTaxless[address(this)] = true;
        isTaxless[feeReceiver] = true;
        isTaxless[address(0)] = true;

        p2pFeePercentage = p2pFeePercentage_;
        buyFeePercentage = buyFeePercentage_;

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

    /// @notice This functions is inherited from OpenZeppelin and implements the transaction fee distribution
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        uint256 feesCollected;
        if (!isTaxless[from] && !isTaxless[to]) {
            if(_isPool(from))
            {
                feesCollected = (amount * buyFeePercentage) / (10**(feeDecimals + 2));
            }else if(!_isPool(to))
            {
                feesCollected = (amount * p2pFeePercentage) / (10**(feeDecimals + 2));
            }
        }

        amount -= feesCollected;
        _balances[from] -= feesCollected;
        _balances[feeReceiver] += feesCollected;

        emit Transfer(from, feeReceiver, amount);
    
        super._transfer(from, to, amount);
    }

    /// @dev Checks if an address is part of the Uniswap V3 pools. This is for internal use.
    function _isPool(address _address) internal view returns(bool)
    {
        return _address == pool1 || _address == pool2 || _address == pool3 || _address == pool4;
    }

    /// @dev Square root function for internal use
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

    /// @notice Set excemptions for transaction fee payments
    /// @param account Address that tax configuration will be affected
    /// @param isTaxless_ If set to true the account will not pay transaction fees
    /// @custom:internal This function is internal, can be overrided.
    function _setTaxless(address account, bool isTaxless_) internal
    {
        isTaxless[account] = isTaxless_;
    }

    /// @notice Changes the address that will recieve fees
    /// @param feeReceiver_ If set to true the account will not pay transaction fees
    /// @custom:internal This function is internal, can be overrided.
    function _setFeeReceiver(address feeReceiver_) internal
    {
        feeReceiver = feeReceiver_;
    }

    /// @notice Changes the address that will recieve fees
    /// @param isFeeActive_ If set to true all transaction fees will not be charged
    /// @custom:internal This function is internal, can be overrided.
    function _setFeeActive(bool isFeeActive_) internal
    {
        isFeeActive = isFeeActive_;
    }

    /// @notice The fee percentage for buy, sell and peer to peer
    /// @param buyFeePercentage_ New buy percentage fee
    /// @param p2pFeePercentage_ New peer to peer percentage fee
    /// @custom:internal This function is internal, can be overrided.
    function _setFees(uint buyFeePercentage_, uint p2pFeePercentage_) internal
    {
        buyFeePercentage = buyFeePercentage_;
        p2pFeePercentage = p2pFeePercentage_;
    }
}