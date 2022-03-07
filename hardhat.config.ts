import { HardhatUserConfig } from "hardhat/config"
import "@nomiclabs/hardhat-waffle"
import "@typechain/hardhat"
import "hardhat-gas-reporter"
import "solidity-coverage"

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
	solidity: {
		compilers: [
			{
				version: "0.8.12",
				settings: {
					optimizer: { enabled: true }
				}
			}
		]
	},
	gasReporter: {
		enabled: true,
		currency: "USD",
	},
}

export default config
