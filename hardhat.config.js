require("@nomicfoundation/hardhat-toolbox");
require('solidity-coverage')
require('dotenv').config()
require('solidity-docgen')

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: '0.8.17',
  networks: {
    hardhat: {
      forking: {
        url: process.env.MAINNET_RPC_URL,
      }
    }
  },
  docgen: {
    pages: 'files',
    exclude: [
      'common',
      'examples',
      'ERC20/interfaces',
      'ERC20/ERC20.sol',
      'ERC721'
    ]
  }
};