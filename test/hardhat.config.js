/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.18",
  networks: {
    hardhat: {
      chainId: 1337
    },
    local: {
      url: "http://127.0.0.1:8545",
      chainId: 1337
    }
  },
  paths: {
    sources: "../dARK_dapp",
    tests: "./contracts",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 40000
  }
};