// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../utils/SubscribableService.sol";

/// @title Mock class for unit testing SubscribableService.sol
/// @dev Also serves as a sample for implementing a SubscribableService
contract SubscribableServiceMock is SubscribableService, Ownable {

	constructor(uint256 price) SubscribableService(price) { }

	/// Sample function that can only be accessed by subscribers
	function subscribableServiceFunction() external view onlySubscriber returns (bool) {
		return true;
	}

	/// Changes the price of the subscription for new subscribers
	function changePrice(uint256 price) external onlyOwner {
		subscriptionPrice_ = price;
	}

	/// Provides access to the sum of subscription fees collected
	function collectedFees() external view returns (uint256) {
		return collectedFees_;
	}

	/// Returns the internal list of subscribers
	/// @dev This sample implementation exposes subscribers to everyone
	function currentSubscribers() external view returns (address[] memory) {
		return subscribers_.addresses;
	}

	/// Withdraws all funds to the owner's wallet
	/// @dev Also resets the collected fees (for unit tests)
	function withdraw() external onlyOwner {
		collectedFees_ = 0;
		Address.sendValue(payable(owner()), address(this).balance);
	}
}
