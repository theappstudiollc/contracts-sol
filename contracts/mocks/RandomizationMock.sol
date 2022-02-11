// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../utils/Randomization.sol";

/// @title Randomization Mock
contract RandomizationMock {

	/// @dev Trailing `_` allows us to pass Slither tests, while also communicating that this value is not public
	uint256 internal seed_;

	/// Constructs a new instance of the Randomization Mock
	/// @param seed An initial seed
	constructor(uint256 seed) {
		seed_ = seed;
	}

	/// Returns a value based on the spread of a random uint8 seed and provided percentages
	function randomIndex(uint8 random, uint8[] memory percentages) external pure returns (uint256) {
		return Randomization.randomIndex(random, percentages);
	}

	/// Returns a random seed suitable for ERC-721 attribute generation when an Oracle such as ChainLink VRF is not available to a contract
	function randomSeed(uint256 initialSeed) external view returns (uint256) {
		return Randomization.randomSeed(initialSeed);
	}

	/// Modifies state so that we can estimate the cost of the `randomSeed()` function
	function randomSeedCost() external {
		seed_ = Randomization.randomSeed(seed_);
	}
}
