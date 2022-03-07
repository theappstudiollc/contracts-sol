// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../utils/OnChain.sol";

/// @title OnChain Mock
contract OnChainMock {

	/// Returns the prefix needed for a base64-encoded on chain svg image
	function baseSvgImageURI() external pure returns (string memory) {
		return OnChain.baseSvgImageURI();
	}

	/// Returns the prefix needed for a base64-encoded on chain nft metadata
	function baseURI() external pure returns (string memory) {
		return OnChain.baseURI();
	}

	/// Returns the contents joined with a comma between them
	function commaSeparated(string memory contents1, string memory contents2) external pure returns (string memory) {
		return OnChain.commaSeparated(contents1, contents2);
	}

	/// Returns the contents joined with commas between them
	function commaSeparated(string memory contents1, string memory contents2, string memory contents3) external pure returns (string memory) {
		return OnChain.commaSeparated(contents1, contents2, contents3);
	}

	/// Returns the contents joined with commas between them
	function commaSeparated(string memory contents1, string memory contents2, string memory contents3, string memory contents4) external pure returns (string memory) {
		return OnChain.commaSeparated(contents1, contents2, contents3, contents4);
	}

	/// Returns the contents joined with commas between them
	function commaSeparated(string memory contents1, string memory contents2, string memory contents3, string memory contents4, string memory contents5) external pure returns (string memory) {
		return OnChain.commaSeparated(contents1, contents2, contents3, contents4, contents5);
	}

	/// Returns the contents joined with commas between them
	function commaSeparated(string memory contents1, string memory contents2, string memory contents3, string memory contents4, string memory contents5, string memory contents6) external pure returns (string memory) {
		return OnChain.commaSeparated(contents1, contents2, contents3, contents4, contents5, contents6);
	}

	/// Returns the contents prefixed by a comma
	function continuesWith(string memory contents) external pure returns (string memory) {
		return OnChain.continuesWith(contents);
	}

	/// Returns the contents wrapped in a json dictionary
	function dictionary(string memory contents) external pure returns (string memory) {
		return OnChain.dictionary(contents);
	}

	/// Returns an unwrapped key/value pair where the value is an array
	function keyValueArray(string memory key, string memory value) external pure returns (string memory) {
		return OnChain.keyValueArray(key, value);
	}

	/// Returns an unwrapped key/value pair where the value is a string
	function keyValueString(string memory key, string memory value) external pure returns (string memory) {
		return OnChain.keyValueString(key, value);
	}

	/// Encodes an SVG as base64 and prefixes it with a URI scheme suitable for on-chain data
	function svgImageURI(string memory svg) external pure returns (string memory) {
		return OnChain.svgImageURI(svg);
	}

	/// Encodes json as base64 and prefixes it with a URI scheme suitable for on-chain data
	function tokenURI(string memory metadata) external pure returns (string memory) {
		return OnChain.tokenURI(metadata);
	}

	/// Returns the json dictionary of a single trait attribute for an ERC-721 or ERC-1155 NFT
	function traitAttribute(string memory name, string memory value) external pure returns (string memory) {
		return OnChain.traitAttribute(name, value);
	}
}
