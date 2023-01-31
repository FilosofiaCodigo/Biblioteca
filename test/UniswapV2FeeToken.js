const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  const { ethers } = require("hardhat");
  
  describe("Uniswap V2 Fee Token", function () {
    async function launchAndAddLiquidity() {
      const blockNumBefore = await ethers.provider.getBlockNumber();
      const blockBefore = await ethers.provider.getBlock(blockNumBefore);
      deadline = blockBefore.timestamp + 500;
  
      const [deployer, walletA, walletB] = await ethers.getSigners();
  
      const MyUniswapV2FeeToken = await ethers.getContractFactory("MyUniswapV2FeeToken");
      const uniswapRouter = await ethers.getContractAt("ISwapRouter", "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D");
      const myUniswapV2FeeToken = await MyUniswapV2FeeToken.deploy();
      const ERC20 = await hre.ethers.getContractFactory("ERC20")
      const usdc = await ERC20.attach("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")
  
      // Get some base tokens
      await uniswapRouter.swapETHForExactTokens(
        ethers.utils.parseUnits("2000.0",6),
        ["0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", usdc.address],
        deployer.address,
        deadline,
        {value: ethers.utils.parseEther("5")}
      )
  
      await myUniswapV2FeeToken.approve(uniswapRouter.address, ethers.utils.parseEther("500000"))
      await usdc.approve(uniswapRouter.address, ethers.utils.parseUnits("1000",6))
  
      await uniswapRouter.addLiquidity(
        myUniswapV2FeeToken.address,
        usdc.address,
        ethers.utils.parseEther("500000"),
        ethers.utils.parseUnits("1000",6),
        ethers.utils.parseEther("0"),
        ethers.utils.parseEther("0"),
        deployer.address,
        deadline)
      return { uniswapRouter, myUniswapV2FeeToken, usdc, walletA, walletB, deadline };
    }
  
    describe("Fee collection", function () {
      it("Should collect fees on P2P", async function () {
        const { uniswapRouter, myUniswapV2FeeToken, usdc, walletA, walletB } = await loadFixture(launchAndAddLiquidity);
        await myUniswapV2FeeToken.transfer(walletA.address, ethers.utils.parseEther("1000"))
        await myUniswapV2FeeToken.connect(walletA).transfer(walletB.address, ethers.utils.parseEther("100"))
        expect(
          ethers.utils.parseEther("99.5")
        ).to.equal(
          await myUniswapV2FeeToken.balanceOf(walletB.address)
        );
        expect(
          ethers.utils.parseUnits("1000.0",6)
        ).to.lessThan(
          await usdc.balanceOf(await myUniswapV2FeeToken.feeReceiver())
        );
      });
  
      it("Should collect fees on Buy", async function () {
        const { uniswapRouter, myUniswapV2FeeToken, usdc, walletA, walletB } = await loadFixture(launchAndAddLiquidity);
        // First, let's give WalletA some USDC
        await usdc.transfer(walletA.address, ethers.utils.parseUnits("10.0",6))
        // Now we swap
        await usdc.connect(walletA).approve(uniswapRouter.address, ethers.utils.parseUnits("100.0",6))
        await uniswapRouter.connect(walletA).swapTokensForExactTokens(
            ethers.utils.parseEther("100"),
            ethers.utils.parseUnits("10.0",6),
            [usdc.address, myUniswapV2FeeToken.address],
            walletA.address,
            deadline)
        expect(
          ethers.utils.parseEther("99")
        ).to.equal(
          await myUniswapV2FeeToken.balanceOf(walletA.address)
        );
        expect(
          ethers.utils.parseUnits("990.0",6)
        ).to.lessThan(
          await usdc.balanceOf(await myUniswapV2FeeToken.feeReceiver())
        );
      });
      it("Should collect fees on Sell", async function () {
        const { uniswapRouter, myUniswapV2FeeToken, usdc, walletA, walletB } = await loadFixture(launchAndAddLiquidity);
        // First, let's give WalletA some Tokens
        await myUniswapV2FeeToken.transfer(walletA.address, ethers.utils.parseEther("1000"))
        // Now we swap
        await myUniswapV2FeeToken.connect(walletA).approve(uniswapRouter.address, ethers.utils.parseEther("1000.0"))
        await uniswapRouter.connect(walletA).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            ethers.utils.parseEther("1000"),
            0,
            [myUniswapV2FeeToken.address, usdc.address],
            walletA.address,
            deadline)
        expect(
          ethers.utils.parseEther("0.0")
        ).to.lessThan(
          await usdc.balanceOf(await myUniswapV2FeeToken.feeReceiver())
        );
        expect(
          ethers.utils.parseUnits("1000.0",6)
        ).to.lessThan(
          await usdc.balanceOf(await myUniswapV2FeeToken.feeReceiver())
        );
      });
    });
  });