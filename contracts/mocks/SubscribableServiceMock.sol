// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/SubscribableService.sol";

/// @title Mock class for unit testing SubscribableService.sol
/// @dev Also serves as a sample for implementing a SubscribableService
contract SubscribableServiceMock is SubscribableService, Ownable {

    constructor(uint256 price) SubscribableService(price) { }

    /// Sample function that can only be accessed by subscribers
    function subscribableServiceFunction() public view onlySubscriber returns (bool) {
        return true;
    }

    /// Changes the price of the subscription for new subscribers
    function changePrice(uint256 price) public onlyOwner {
        _subscriptionPrice = price;
    }

    /// Provides access to the sum of subscription fees collected
    function collectedFees() public view returns (uint256) {
        return _collectedFees;
    }

    /// Returns the internal list of subscribers
    /// @dev This sample implementation exposes subscribers to everyone
    function currentSubscribers() public view returns (address[] memory) {
        return _subscribers.addresses;
    }

    /// Withdraws all funds to the owner's wallet
    /// @dev Also resets the collected fees
    function withdraw() public payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
        _collectedFees = 0;
    }
}
