// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev String operations with decimals
library DecimalStrings {

	/// @dev Converts a `uint256` to its ASCII `string` representation with decimal places.
	function toDecimalString(uint256 value, uint256 decimals, bool isNegative) internal pure returns (bytes memory) {
		// Inspired by OpenZeppelin's implementation - MIT license
		// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol

		uint256 temp = value;
		uint256 characters = 0;
		unchecked { // `characters` upper-bounded by factor of 10, `decimals` not subtracted unless `characters` is <=
			do {
				characters++;
				temp /= 10;
			} while (temp != 0);
			if (characters <= decimals) {
				characters += 2 + (decimals - characters);
			} else if (decimals > 0) {
				characters += 1;
			}
			temp = isNegative ? 1 : 0; // reuse 'temp' as a sign symbol offset
			characters += temp;
		}
		bytes memory buffer = new bytes(characters);
		while (characters > temp) {
			unchecked { // `characters` always >= 0, `characters` always < `buffer.length` (thus -1 is ok), `buffer[characters]` range is 46,48-57
				characters -= 1;
				if (decimals > 0 && (buffer.length - characters - 1) == decimals) {
					buffer[characters] = bytes1(uint8(46));
					decimals = 0; // Cut off any further checks for the decimal place
				} else if (value != 0) {
					buffer[characters] = bytes1(uint8(48 + uint256(value % 10)));
					value /= 10;
				} else {
					buffer[characters] = bytes1(uint8(48));
				}
			}
		}
		if (isNegative) {
			buffer[0] = bytes1(uint8(45));
		}
		return buffer;
	}
}
