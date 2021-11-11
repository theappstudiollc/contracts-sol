require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
          version: "0.8.9",
          settings: {
              optimizer: { enabled: true }
          }
      }
    ]
  },
  gasReporter: {
    enabled: true,
    currency: "USD"
  },
};
