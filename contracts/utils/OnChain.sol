// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Base64.sol";

/// @title OnChain metadata support library
/**
* @dev These methods are best suited towards view/pure only function calls (ALL the way through the call stack).
* Do not waste gas using these methods in functions that also update state, unless your need requires it.
*/
library OnChain {

	/// Returns the prefix needed for a base64-encoded on chain svg image
	function baseSvgImageURI() internal pure returns (string memory) {
		return "data:image/svg+xml;base64,";
	}

	/// Returns the prefix needed for a base64-encoded on chain nft metadata
	function baseURI() internal pure returns (string memory) {
		return "data:application/json;base64,";
	}

	/// Returns the contents joined with a comma between them
	/// @param contents1 The first content to join
	/// @param contents2 The second content to join
	/// @return A string that represent all contents joined with a comma
	function commaSeparated(string memory contents1, string memory contents2) internal pure returns (string memory) {
		return string.concat(contents1, continuesWith(contents2));
	}

	/// Returns the contents joined with commas between them
	/// @param contents1 The first content to join
	/// @param contents2 The second content to join
	/// @param contents3 The third content to join
	/// @return A string that represent all contents joined with commas
	function commaSeparated(string memory contents1, string memory contents2, string memory contents3) internal pure returns (string memory) {
		return string.concat(commaSeparated(contents1, contents2), continuesWith(contents3));
	}

	/// Returns the contents joined with commas between them
	/// @param contents1 The first content to join
	/// @param contents2 The second content to join
	/// @param contents3 The third content to join
	/// @param contents4 The fourth content to join
	/// @return A string that represent all contents joined with commas
	function commaSeparated(string memory contents1, string memory contents2, string memory contents3, string memory contents4) internal pure returns (string memory) {
		return string.concat(commaSeparated(contents1, contents2, contents3), continuesWith(contents4));
	}

	/// Returns the contents joined with commas between them
	/// @param contents1 The first content to join
	/// @param contents2 The second content to join
	/// @param contents3 The third content to join
	/// @param contents4 The fourth content to join
	/// @param contents5 The fifth content to join
	/// @return A string that represent all contents joined with commas
	function commaSeparated(string memory contents1, string memory contents2, string memory contents3, string memory contents4, string memory contents5) internal pure returns (string memory) {
		return string.concat(commaSeparated(contents1, contents2, contents3, contents4), continuesWith(contents5));
	}

	/// Returns the contents joined with commas between them
	/// @param contents1 The first content to join
	/// @param contents2 The second content to join
	/// @param contents3 The third content to join
	/// @param contents4 The fourth content to join
	/// @param contents5 The fifth content to join
	/// @param contents6 The sixth content to join
	/// @return A string that represent all contents joined with commas
	function commaSeparated(string memory contents1, string memory contents2, string memory contents3, string memory contents4, string memory contents5, string memory contents6) internal pure returns (string memory) {
		return string.concat(commaSeparated(contents1, contents2, contents3, contents4, contents5), continuesWith(contents6));
	}

	/// Returns the contents prefixed by a comma
	/// @dev This is used to append multiple attributes into the json
	/// @param contents The contents with which to prefix
	/// @return A string of the contents prefixed with a comma
	function continuesWith(string memory contents) internal pure returns (string memory) {
		return string.concat(",", contents);
	}

	/// Returns the contents wrapped in a json dictionary
	/// @param contents The contents with which to wrap
	/// @return A string of the contents wrapped as a json dictionary
	function dictionary(string memory contents) internal pure returns (string memory) {
		return string.concat("{", contents, "}");
	}

	/// Returns an unwrapped key/value pair where the value is an array
	/// @param key The name of the key used in the pair
	/// @param value The value of pair, as an array
	/// @return A string that is suitable for inclusion in a larger dictionary
	function keyValueArray(string memory key, string memory value) internal pure returns (string memory) {
		return string.concat("\"", key, "\":[", value, "]");
	}

	/// Returns an unwrapped key/value pair where the value is a string
	/// @param key The name of the key used in the pair
	/// @param value The value of pair, as a string
	/// @return A string that is suitable for inclusion in a larger dictionary
	function keyValueString(string memory key, string memory value) internal pure returns (string memory) {
		return string.concat("\"", key, "\":\"", value, "\"");
	}

	/// Encodes an SVG as base64 and prefixes it with a URI scheme suitable for on-chain data
	/// @param svg The contents of the svg
	/// @return A string that may be added to the "image" key/value pair in ERC-721 or ERC-1155 metadata
	function svgImageURI(string memory svg) internal pure returns (string memory) {
		return string.concat(baseSvgImageURI(), Base64.encode(bytes(svg)));
	}

	/// Encodes json as base64 and prefixes it with a URI scheme suitable for on-chain data
	/// @param metadata The contents of the metadata
	/// @return A string that may be returned as the tokenURI in a ERC-721 or ERC-1155 contract
	function tokenURI(string memory metadata) internal pure returns (string memory) {
		return string.concat(baseURI(), Base64.encode(bytes(metadata)));
	}

	/// Returns the json dictionary of a single trait attribute for an ERC-721 or ERC-1155 NFT
	/// @param name The name of the trait
	/// @param value The value of the trait
	/// @return A string that can be embedded within a larger array of attributes
	function traitAttribute(string memory name, string memory value) internal pure returns (string memory) {
		return dictionary(commaSeparated(
			keyValueString("trait_type", name),
			keyValueString("value", value)
		));
	}
}
