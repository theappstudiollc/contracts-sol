// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../utils/SVG.sol";

/// @title Mock class for unit testing SVG.sol
contract SVGMock {

	/// Returns a named element based on the supplied attributes and contents
	function createElement(string memory name, string memory attributes, string memory contents) external pure returns (string memory) {
		return SVG.createElement(name, attributes, contents);
	}

	/// Returns the root SVG attributes based on the supplied width and height
	function svgAttributes(uint256 width, uint256 height) external pure returns (string memory) {
		return SVG.svgAttributes(width, height);
	}

	/// Returns an RGB string suitable as an attribute for SVG elements based on the supplied Color and ColorType
	/// @dev includes necessary leading space for all types _except_ None
	function colorAttribute(ISVGTypes.ColorAttribute attribute, string memory value) external pure returns (string memory) {
		return SVG.colorAttribute(attribute, value);
	}

	/// Returns an RGB color attribute value
	function colorAttributeRGBValue(ISVGTypes.Color memory color) external pure returns (string memory) {
		return SVG.colorAttributeRGBValue(color);
	}

	/// Returns a URL color attribute value
	function colorAttributeURLValue(string memory url) external pure returns (string memory) {
		return SVG.colorAttributeURLValue(url);
	}

	/// Returns a Color that is brightened by the provided percentage
	function brightenColor(ISVGTypes.Color memory source, uint8 percentage, uint8 minimumBump) external pure returns (ISVGTypes.Color memory color) {
		return SVG.brightenColor(source, percentage, minimumBump);
	}

	/// Returns an ISVGTypes.Color based on a packed representation of r, g, and b
	function fromPackedColor(uint24 packedColor) external pure returns (ISVGTypes.Color memory color) {
		return SVG.fromPackedColor(packedColor);
	}

	/// Returns a mixed Color by balancing the ratio between `color1` and `color2`, with a total percentage (for overmixing and undermixing outside the source bounds)
	function mixColors(ISVGTypes.Color memory color1, ISVGTypes.Color memory color2, uint8 ratioPercentage, uint8 totalPercentage) external pure returns (ISVGTypes.Color memory color) {
		return SVG.mixColors(color1, color2, ratioPercentage, totalPercentage);
	}

	/// Returns a proportionally-randomized Color between the start and stop colors using a random Color seed
	function randomizeColors(ISVGTypes.Color memory start, ISVGTypes.Color memory stop, ISVGTypes.Color memory random) external pure returns (ISVGTypes.Color memory color) {
		return SVG.randomizeColors(start, stop, random);
	}
}
