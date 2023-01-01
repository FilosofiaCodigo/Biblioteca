const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const { BigNumber } = require('bignumber.js')
const Q192 = BigNumber(2).exponentiatedBy(192)

function calculateSqrtPriceX96(price, token0Dec, token1Dec)
{
  price = BigNumber(price).shiftedBy(token1Dec - token0Dec)
  ratioX96 = price.multipliedBy(Q192)
  sqrtPriceX96 = ratioX96.sqrt()
  return sqrtPriceX96
}

function getNearestUsableTick(currentTick,space) {
  if(currentTick == 0){
      return 0
  }
  direction = (currentTick >= 0) ? 1 : -1
  currentTick *= direction
  nearestTick = (currentTick%space <= space/2) ? currentTick - (currentTick%space) : currentTick + (space-(currentTick%space))
  nearestTick *= direction
  
  return nearestTick
}

describe("Uniswap V3 Fee Token", function () {
  async function deployFixture() {
    const [deployer, user1, user2, user3] = await ethers.getSigners();

    const MyUniswapV3FeeToken = await ethers.getContractFactory("MyUniswapV3FeeToken");
    const myUniswapV3FeeToken = await MyUniswapV3FeeToken.deploy();

    const nonfungiblePositionManager = await hre.ethers.getContractAt(
      "INonfungiblePositionManager", "0xC36442b4a4522E871399CD717aBDD847Ab11FE88"
    );

    const weth = await hre.ethers.getContractAt(
      "IWETH", "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
    );

    const router = await hre.ethers.getContractAt(
      "IUniswapV3Router", "0xE592427A0AEce92De3Edee1F18E0157C05861564"
    );

    await weth.deposit({value: ethers.utils.parseEther("200")})
    await weth.connect(user1).deposit({value: ethers.utils.parseEther("200")})

    return { myUniswapV3FeeToken, nonfungiblePositionManager, router, weth, deployer, user1, user2, user3 };
  }

  async function addLiquidityFixiture() {
    const { myUniswapV3FeeToken, nonfungiblePositionManager, router, weth, deployer, user1, user2, user3 } = await loadFixture(deployFixture);

    const pool = await hre.ethers.getContractAt(
      "IUniswapV3Pool", await myUniswapV3FeeToken.pool4()
    );

    let slot0 = await pool.slot0()
    let tickSpacing = parseInt(await pool.tickSpacing())
    let nearestTick = getNearestUsableTick(parseInt(slot0.tick),tickSpacing)

    if(myUniswapV3FeeToken.address.toLowerCase() < weth.address.toLowerCase())
    {
      token0 = myUniswapV3FeeToken.address
      token1 = weth.address
      amount0Desired = "100000"
      amount1Desired = "100"
    }else
    {
      token0 = weth.address
      token1 = myUniswapV3FeeToken.address
      amount0Desired = "100"
      amount1Desired = "100000"
    }

    mintParams = {
        token0: token0,
        token1: token1,
        fee: await pool.fee(),
        tickLower: nearestTick - tickSpacing * 10,
        tickUpper: nearestTick + tickSpacing * 10,
        amount0Desired: ethers.utils.parseEther(amount0Desired),
        amount1Desired: ethers.utils.parseEther(amount1Desired),
        amount0Min: 0,
        amount1Min: 0,
        recipient: deployer.address,
        deadline: "2662503213"
    };

    await myUniswapV3FeeToken.approve(nonfungiblePositionManager.address, ethers.utils.parseEther("1000000"))
    await weth.approve(nonfungiblePositionManager.address, ethers.utils.parseEther("100"))
    await nonfungiblePositionManager.connect(deployer).mint(
      mintParams
      );

    return { myUniswapV3FeeToken, nonfungiblePositionManager, router, pool, weth, deployer, user1, user2, user3 };
  }

  describe("User 1 buys 1 eth worth of tokens", function () {
    it("User 1 should get about 1000 tokens", async function () {
      const { myUniswapV3FeeToken, nonfungiblePositionManager, router, pool, weth, deployer, user1, user2, user3 } = await loadFixture(addLiquidityFixiture);
      var user1TokenBeforeBuy = ethers.utils.formatEther(await myUniswapV3FeeToken.balanceOf(user1.address))
      buyParams = {
          tokenIn: weth.address,
          tokenOut: myUniswapV3FeeToken.address,
          fee: await pool.fee(),
          recipient: user1.address,
          deadline: "2662503213",
          amountIn: ethers.utils.parseEther("1"),
          amountOutMinimum: 0,
          sqrtPriceLimitX96: 0
      }
      await weth.connect(user1).approve(router.address, ethers.utils.parseEther("1"))
      await router.connect(user1).exactInputSingle(buyParams)
      var user1TokenAfterBuy = ethers.utils.formatEther(await myUniswapV3FeeToken.balanceOf(user1.address))
      expect(user1TokenAfterBuy - user1TokenBeforeBuy).to.above(900);
    });

    it("Vault should collect about 10 tokens in fees", async function () {
      const { myUniswapV3FeeToken, nonfungiblePositionManager, router, pool, weth, deployer, user1, user2, user3 } = await loadFixture(addLiquidityFixiture);
      var vaultTokenBeforeBuy = ethers.utils.formatEther(await myUniswapV3FeeToken.balanceOf(await myUniswapV3FeeToken.tokenVaultAddress()))
      buyParams = {
          tokenIn: weth.address,
          tokenOut: myUniswapV3FeeToken.address,
          fee: await pool.fee(),
          recipient: user1.address,
          deadline: "2662503213",
          amountIn: ethers.utils.parseEther("1"),
          amountOutMinimum: 0,
          sqrtPriceLimitX96: 0
      }
      await weth.connect(user1).approve(router.address, ethers.utils.parseEther("1"))
      await router.connect(user1).exactInputSingle(buyParams)
      var vaultTokenAfterBuy = ethers.utils.formatEther(await myUniswapV3FeeToken.balanceOf(await myUniswapV3FeeToken.tokenVaultAddress()))
      expect(vaultTokenAfterBuy - vaultTokenBeforeBuy).to.above(9);
    });
  });

  describe("User1 gets 1000 tokens and then sells it", function () {
    it("User1 should get around 1 ether", async function () {
      const { myUniswapV3FeeToken, nonfungiblePositionManager, router, pool, weth, deployer, user1, user2, user3 } = await loadFixture(addLiquidityFixiture);
      
      await myUniswapV3FeeToken.transfer(user1.address, ethers.utils.parseEther("900"))
      var user1WEthBeforeSell = ethers.utils.formatEther(await weth.balanceOf(user1.address))

      sellParams = {
        tokenIn: myUniswapV3FeeToken.address,
        tokenOut: weth.address,
        fee: await pool.fee(),
        recipient: user1.address,
        deadline: "2662503213",
        amountIn: ethers.utils.parseEther("900"),
        amountOutMinimum: 0,
        sqrtPriceLimitX96: 0
      }

      await myUniswapV3FeeToken.connect(user1).approve(router.address, ethers.utils.parseEther("1000"))
      await router.connect(user1).exactInputSingle(sellParams)

      var user1WEthAfterSell = ethers.utils.formatEther(await weth.balanceOf(user1.address))
      expect(user1WEthAfterSell - user1WEthBeforeSell).to.above(0.9);
    });

    it("Vault should not get any tokens", async function () {
      const { myUniswapV3FeeToken, nonfungiblePositionManager, router, pool, weth, deployer, user1, user2, user3 } = await loadFixture(addLiquidityFixiture);
      
      await myUniswapV3FeeToken.transfer(user1.address, ethers.utils.parseEther("900"))

      var vaultTokenBeforeSell = ethers.utils.formatEther(await myUniswapV3FeeToken.balanceOf(await myUniswapV3FeeToken.tokenVaultAddress()))

      sellParams = {
        tokenIn: myUniswapV3FeeToken.address,
        tokenOut: weth.address,
        fee: await pool.fee(),
        recipient: user1.address,
        deadline: "2662503213",
        amountIn: ethers.utils.parseEther("900"),
        amountOutMinimum: 0,
        sqrtPriceLimitX96: 0
      }

      await myUniswapV3FeeToken.connect(user1).approve(router.address, ethers.utils.parseEther("1000"))
      await router.connect(user1).exactInputSingle(sellParams)

      var vaultTokenAfterSell = ethers.utils.formatEther(await myUniswapV3FeeToken.balanceOf(await myUniswapV3FeeToken.tokenVaultAddress()))
      expect(vaultTokenAfterSell - vaultTokenBeforeSell).to.equal(0);
    });
  });

  describe("User1 get 1000 tokens then send them to User2", function () {
    it("User2 should get 980 tokens", async function () {
      const { myUniswapV3FeeToken, nonfungiblePositionManager, router, pool, weth, deployer, user1, user2, user3 } = await loadFixture(addLiquidityFixiture);

      await myUniswapV3FeeToken.transfer(user1.address, ethers.utils.parseEther("1000"))

      var user2TokenBeforeSell = ethers.utils.formatEther(await myUniswapV3FeeToken.balanceOf(user2.address))
      await myUniswapV3FeeToken.connect(user1).transfer(user2.address, ethers.utils.parseEther("1000"))
      var user2TokenAfterSell = ethers.utils.formatEther(await myUniswapV3FeeToken.balanceOf(user2.address))

      expect(user2TokenAfterSell - user2TokenBeforeSell).to.equal(980);
    });

    it("Vault should get 20 tokens", async function () {
      const { myUniswapV3FeeToken, nonfungiblePositionManager, router, pool, weth, deployer, user1, user2, user3 } = await loadFixture(addLiquidityFixiture);

      await myUniswapV3FeeToken.transfer(user1.address, ethers.utils.parseEther("1000"))

      var vaultTokenBeforeSell = ethers.utils.formatEther(await myUniswapV3FeeToken.balanceOf(await myUniswapV3FeeToken.tokenVaultAddress()))
      await myUniswapV3FeeToken.connect(user1).transfer(user2.address, ethers.utils.parseEther("1000"))
      var vaultTokenAfterSell = ethers.utils.formatEther(await myUniswapV3FeeToken.balanceOf(await myUniswapV3FeeToken.tokenVaultAddress()))

      expect(vaultTokenAfterSell - vaultTokenBeforeSell).to.equal(20);
    });
  });
});