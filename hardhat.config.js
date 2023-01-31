require("@nomicfoundation/hardhat-toolbox");
require('solidity-coverage')
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      forking: {
        url: process.env.MAINNET_RPC_URL,
      }
    }
  }
};