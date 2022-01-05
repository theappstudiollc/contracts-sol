// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../utils/DecimalStrings.sol";

/// @title DecimalStrings Mock
contract DecimalStringsMock {

    /// @dev Converts a `uint256` to its ASCII `string` decimal representation with decimal places.
    function toDecimalString(uint256 value, uint256 decimals, bool isNegative) external pure returns (string memory) {
        return string(DecimalStrings.toDecimalString(value, decimals, isNegative));
    }
}
