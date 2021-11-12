// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Interface for definiting a subscribable service
interface ISubscribableService {

    /// Returns the one-time price (in Wei) for access to all functions in a subscribable service
    function subscriptionPrice() external returns (uint256);

    /// Returns whether the subscriber at address is subscribed to the service
    /// @param subscriber The address for which the current subscription status is desired
    /// @return A bool declaring whether the `subscriber` address has a subscription to the service
    function isSubscribed(address subscriber) external returns (bool);

    /// Subscribes to the service, passing in the subscriptionPrice as payable
    /// @param subscriber The address that is allowed to make calls to the service
    function subscribe(address subscriber) external payable;
}
