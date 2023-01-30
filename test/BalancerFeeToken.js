const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  const { ethers } = require("hardhat");
  
  describe("Balancer Fee Token", function () {
    async function initSetup() {
      const blockNumBefore = await ethers.provider.getBlockNumber();
      const blockBefore = await ethers.provider.getBlock(blockNumBefore);
      const timestamp = blockBefore.timestamp;
  
      const [deployer, walletA, walletB] = await ethers.getSigners();

      const MyBalancerFeeToken = await ethers.getContractFactory("MyBalancerFeeToken");
      const weightedPool2TokensFactory = await ethers.getContractAt("IWeightedPool2TokensFactory", "0xA5bf2ddF098bb0Ef6d120C98217dD6B141c74EE0");
      const myBalancerFeeToken = await MyBalancerFeeToken.deploy();
      const weth = await hre.ethers.getContractAt(
        "IWETH", "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
      );
      const vault = await hre.ethers.getContractAt(
        "IVault", "0xBA12222222228d8Ba445958a75a0704d566BF2C8"
      );

      await weth.deposit({value: ethers.utils.parseEther("200")})
      await weth.connect(walletA).deposit({value: ethers.utils.parseEther("200")})

      let token0;
      let token1;
      if(myBalancerFeeToken.address.toLowerCase() < weth.address.toLowerCase())
      {
        token0 = myBalancerFeeToken.address.toLowerCase();
        token1 = weth.address.toLowerCase();
      }else
      {
        token0 = weth.address.toLowerCase();
        token1 = myBalancerFeeToken.address.toLowerCase();
      }
      
      weightedPoolAddress = await weightedPool2TokensFactory.callStatic.create(
          "My Weighted Pool", // Name
          "MWP",              // Symbol
          [token0, token1],   // Tokens
          [ethers.utils.parseEther("0.5"), ethers.utils.parseEther("0.5")], // Weights
          ethers.utils.parseEther("0.01"),  // Swap Fee Percentage
          false,              // Oracle Enabled
          ethers.constants.AddressZero      // Owner
      );

      await weightedPool2TokensFactory.create(
        "My Weighted Pool", // Name
        "MWP",              // Symbol
        [token0, token1],   // Tokens
        [ethers.utils.parseEther("0.5"), ethers.utils.parseEther("0.5")], // Weights
        ethers.utils.parseEther("0.01"),  // Swap Fee Percentage
        false,              // Oracle Enabled
        ethers.constants.AddressZero      // Owner
      );

      const weightedPool = await hre.ethers.getContractAt(
        "IWeightedPool", weightedPoolAddress
      );

      return { myBalancerFeeToken, weth, weightedPool, vault, deployer, walletA, walletB, timestamp };
    }

    async function addLiquidity() {
      const { myBalancerFeeToken, weth, weightedPool, vault, deployer, walletA, walletB, timestamp } = await loadFixture(initSetup);

      await weth.approve(vault.address, ethers.utils.parseEther("100"))
      await myBalancerFeeToken.approve(vault.address, ethers.utils.parseEther("100000"))
    
      const JOIN_KIND_INIT = 0;
      var initialBalances = [ethers.utils.parseEther("100"), ethers.utils.parseEther("100000")]
      var tokens = [weth.address, myBalancerFeeToken.address]
      if(myBalancerFeeToken.address < weth.address)
      {
        tokens = [myBalancerFeeToken.address, weth.address]
        initialBalances = [ethers.utils.parseEther("100000"), ethers.utils.parseEther("100")]
      }
      const initUserData =
      ethers.utils.defaultAbiCoder.encode(['uint256', 'uint256[]'], 
                                          [JOIN_KIND_INIT, initialBalances]);
      var joinPoolRequest = [
        tokens,
        initialBalances, // maxAmountsIn
        initUserData,
        false // fromInternalBalance
      ]

      await vault.joinPool(
        await weightedPool.getPoolId(),
        deployer.address,
        deployer.address,
        joinPoolRequest
      )
  
      return { myBalancerFeeToken, weth, weightedPool, vault, deployer, walletA, walletB, timestamp };
    }
  
    describe("Fee collection", function () {
      it("Should collect fees on P2P", async function () {
        const { myBalancerFeeToken, weth, weightedPool, vault, deployer, walletA, walletB, timestamp } = await loadFixture(addLiquidity);

        await myBalancerFeeToken.transfer(walletA.address, ethers.utils.parseEther("100.0"))
        await myBalancerFeeToken.connect(walletA).transfer(walletB.address, ethers.utils.parseEther("100.0"))
        
        expect(
          await myBalancerFeeToken.balanceOf(await myBalancerFeeToken.tokenVaultAddress())
        ).to.greaterThan(
          0
        );
      });

      it("Should collect fees on Buy", async function () {
        const { myBalancerFeeToken, weth, weightedPool, vault, deployer, walletA, walletB, timestamp } = await loadFixture(addLiquidity);

        const swap_kind = 0; // Single Swap
        const swap_struct = {
            poolId: await weightedPool.getPoolId(),
            kind: swap_kind,
            assetIn: weth.address,
            assetOut: myBalancerFeeToken.address,
            amount: ethers.utils.parseEther("0.01"),
            userData: '0x'
        };
      
        const fund_struct = {
            sender: walletA.address,
            fromInternalBalance: false,
            recipient: walletA.address,
            toInternalBalance: false
        };
        await weth.connect(walletA).approve(vault.address, ethers.utils.parseEther("100"))
        await vault.connect(walletA).swap(
          swap_struct,
          fund_struct,
          ethers.utils.parseEther("0.0"), // Limit
          timestamp + 100); // Deadline
        
        expect(
          await myBalancerFeeToken.balanceOf(await myBalancerFeeToken.tokenVaultAddress())
        ).to.greaterThan(
          0
        );
      });

      it("Should collect fees on Sell", async function () {
        const { myBalancerFeeToken, weth, weightedPool, vault, deployer, walletA, walletB, timestamp } = await loadFixture(addLiquidity);

        await myBalancerFeeToken.transfer(walletA.address, ethers.utils.parseEther("100.0"))

        const swap_kind = 0; // Single Swap
        const swap_struct = {
            poolId: await weightedPool.getPoolId(),
            kind: swap_kind,
            assetIn: myBalancerFeeToken.address,
            assetOut: weth.address,
            amount: ethers.utils.parseEther("100"),
            userData: '0x'
        };
      
        const fund_struct = {
            sender: walletA.address,
            fromInternalBalance: false,
            recipient: walletA.address,
            toInternalBalance: false
        };
        await myBalancerFeeToken.connect(walletA).approve(vault.address, ethers.utils.parseEther("100"))
        await vault.connect(walletA).swap(
          swap_struct,
          fund_struct,
          ethers.utils.parseEther("0.0"), // Limit
          timestamp + 100); // Deadline
        
        expect(
          await myBalancerFeeToken.balanceOf(await myBalancerFeeToken.tokenVaultAddress())
        ).to.greaterThan(
          0
        );
      });
    });
  });