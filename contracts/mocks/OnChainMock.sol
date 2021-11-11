// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../utils/OnChain.sol";

/// @title OnChain Mock
contract OnChainMock {

    /// Returns the prefix needed for a base64-encoded on chain svg image
    function baseSvgImageURI() public pure returns (string memory) {
        return string(OnChain.baseSvgImageURI());
    }

    /// Returns the prefix needed for a base64-encoded on chain nft metadata
    function baseURI() public pure returns (string memory) {
        return string(OnChain.baseURI());
    }

    /// Returns the contents joined with a comma between them
    function commaSeparated(string memory contents1, string memory contents2) public pure returns (string memory) {
        return string(OnChain.commaSeparated(bytes(contents1), bytes(contents2)));
    }

    /// Returns the contents joined with commas between them
    function commaSeparated(string memory contents1, string memory contents2, string memory contents3) public pure returns (string memory) {
        return string(OnChain.commaSeparated(bytes(contents1), bytes(contents2), bytes(contents3)));
    }

    /// Returns the contents joined with commas between them
    function commaSeparated(string memory contents1, string memory contents2, string memory contents3, string memory contents4) public pure returns (string memory) {
        return string(OnChain.commaSeparated(bytes(contents1), bytes(contents2), bytes(contents3), bytes(contents4)));
    }

    /// Returns the contents joined with commas between them
    function commaSeparated(string memory contents1, string memory contents2, string memory contents3, string memory contents4, string memory contents5) public pure returns (string memory) {
        return string(OnChain.commaSeparated(bytes(contents1), bytes(contents2), bytes(contents3), bytes(contents4), bytes(contents5)));
    }

    /// Returns the contents joined with commas between them
    function commaSeparated(string memory contents1, string memory contents2, string memory contents3, string memory contents4, string memory contents5, string memory contents6) public pure returns (string memory) {
        return string(OnChain.commaSeparated(bytes(contents1), bytes(contents2), bytes(contents3), bytes(contents4), bytes(contents5), bytes(contents6)));
    }

    /// Returns the contents prefixed by a comma
    function continuesWith(string memory contents) public pure returns (string memory) {
        return string(OnChain.continuesWith(bytes(contents)));
    }

    /// Returns the contents wrapped in a json dictionary
    function dictionary(string memory contents) public pure returns (string memory) {
        return string(OnChain.dictionary(bytes(contents)));
    }

    /// Returns an unwrapped key/value pair where the value is an array
    function keyValueArray(string memory key, string memory value) public pure returns (string memory) {
        return string(OnChain.keyValueArray(key, bytes(value)));
    }

    /// Returns an unwrapped key/value pair where the value is a string
    function keyValueString(string memory key, string memory value) public pure returns (string memory) {
        return string(OnChain.keyValueString(key, bytes(value)));
    }

    /// Encodes an SVG as base64 and prefixes it with a URI scheme suitable for on-chain data
    function svgImageURI(string memory svg) public pure returns (string memory) {
        return string(OnChain.svgImageURI(bytes(svg)));
    }

    /// Encodes json as base64 and prefixes it with a URI scheme suitable for on-chain data
    function tokenURI(string memory metadata) public pure returns (string memory) {
        return string(OnChain.tokenURI(bytes(metadata)));
    }

    /// Returns the json dictionary of a single trait attribute for an ERC-721 or ERC-1155 NFT
    function traitAttribute(string memory name, string memory value) public pure returns (string memory) {
        return string(OnChain.traitAttribute(name, bytes(value)));
    }
}
