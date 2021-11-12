// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "../interfaces/ISubscribableService.sol";

/// Error thrown when a call to subscribe uses an address that is already subscribed
/// @dev This error is meant to save money on inadvertant calls to re-subscribe
error AddressAlreadySubscribed();

/// @dev Contract authors should revert with this error when a subscribable function is called by a non-subscriber
error CallerNotSubscribed();

/// Error thrown when a call to subscribe does not include the required subscription price
error InvalidSubscriptionPrice();

/// @title Support contract for enabling subscriptions to services
/// @dev This contract is meant to be a subclass of a contract that provides a service
/// @notice Subclassors should not forget to include some kind of withdraw function that provides access to the subscription fees
abstract contract SubscribableService is ISubscribableService, Context, ReentrancyGuard {

    /// Contains information about subscribers, 
    struct Subscribers {
        address[] addresses;
        mapping (address => bool) lookup;
    }

    /// The collection of subscribers to this service
    /// @dev This value is internal in case subclasses wish to access the list of subscribers
    Subscribers internal _subscribers;

    /// The price in Wei for any subscription
    /// @dev This value is internal in case subclasses wish to modify the price based on other factors
    /// @notice By default, changing the price does not invalidate any pre-existing subscriptions
    uint256 internal _subscriptionPrice;

    /// The total of subscription fees collected
    /// @dev This value is internal in case subclasses wish to withdraw contract balances that are specific to subscriptions
    uint256 internal _collectedFees;

    /// Constructs a new instance of the SubscribableService support contract
    /// @param price The price in Wei for the services provided by the contract
    constructor(uint256 price) {
        _subscriptionPrice = price;
    }

    /// Convenience modifier that prevents non-subscribers from being able to access a function
    modifier onlySubscriber() {
        if (!_subscribers.lookup[_msgSender()]) revert CallerNotSubscribed();
        _;
    }

    /// Returns the one-time price for access to all functions in a subscribable service
    function subscriptionPrice() public view returns (uint256) {
        return _subscriptionPrice;
    }

    /// Returns whether the subscriber at address is subscribed to the service
    /// @param subscriber The address for which the current subscription status is desired
    /// @return A bool declaring whether the `subscriber` address has a subscription to the service
    function isSubscribed(address subscriber) external view returns (bool) {
        return _subscribers.lookup[subscriber];
    }

    /// Subscribes to the service, passing in the subscriptionPrice as payable
    /// @param subscriber The address that is allowed to make calls to the service
    function subscribe(address subscriber) external payable nonReentrant {
        if (msg.value < subscriptionPrice()) revert InvalidSubscriptionPrice();
        if (_subscribers.lookup[subscriber]) revert AddressAlreadySubscribed();
        _subscribers.addresses.push(subscriber);
        _subscribers.lookup[subscriber] = true;
        _collectedFees += msg.value;
    }
}
