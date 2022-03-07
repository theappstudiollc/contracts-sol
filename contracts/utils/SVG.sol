// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/ISVGTypes.sol";
import "./OnChain.sol";
import "./SVGErrors.sol";

/// @title SVG image library
/**
* @dev These methods are best suited towards view/pure only function calls (ALL the way through the call stack).
* Do not waste gas using these methods in functions that also update state, unless your need requires it.
*/
library SVG {

	using Strings for uint256;

	/// Returns a named element based on the supplied attributes and contents
	/// @dev attributes and contents is usually generated from string.concat, attributes is expecting a leading space
	/// @param name The name of the element
	/// @param attributes The attributes of the element, with a leading space
	/// @param contents The contents of the element
	/// @return a string representing the whole element
	function createElement(string memory name, string memory attributes, string memory contents) internal pure returns (string memory) {
		return string.concat(
			"<", bytes(attributes).length == 0 ? name : string.concat(name, attributes),
			bytes(contents).length == 0 ? "/>" : string.concat(">", contents, "</", name, ">")
		);
	}

	/// Returns the root SVG attributes based on the supplied width and height
	/// @dev includes necessary leading space for createElement's `attributes` parameter
	/// @param width The width of the SVG view box
	/// @param height The height of the SVG view box
	/// @return a string representing the root SVG attributes, including a leading space
	function svgAttributes(uint256 width, uint256 height) internal pure returns (string memory) {
		return string.concat(" viewBox='0 0 ", width.toString(), " ", height.toString(), "' xmlns='http://www.w3.org/2000/svg'");
	}

	/// Returns an RGB string suitable as an attribute for SVG elements based on the supplied Color and ColorType
	/// @dev includes necessary leading space for all types _except_ None
	/// @param attribute The `ISVGTypes.ColorAttribute` of the desired attribute
	/// @param value The converted color value
	/// @return a string representing a color attribute in an SVG element
	function colorAttribute(ISVGTypes.ColorAttribute attribute, string memory value) internal pure returns (string memory) {
		if (attribute == ISVGTypes.ColorAttribute.Fill) return _attribute("fill", value);
		if (attribute == ISVGTypes.ColorAttribute.Stop) return _attribute("stop-color", value);
		return _attribute("stroke", value); // Fallback to Stroke
	}

	/// Returns an RGB color attribute value
	/// @param color The `ISVGTypes.Color` of the color
	/// @return a string representing the url attribute value
	function colorAttributeRGBValue(ISVGTypes.Color memory color) internal pure returns (string memory) {
		return _colorValue(ISVGTypes.ColorAttributeKind.RGB, OnChain.commaSeparated(
			uint256(color.red).toString(),
			uint256(color.green).toString(),
			uint256(color.blue).toString()
		));
	}

	/// Returns a URL color attribute value
	/// @param url The url to the color
	/// @return a string representing the url attribute value
	function colorAttributeURLValue(string memory url) internal pure returns (string memory) {
		return _colorValue(ISVGTypes.ColorAttributeKind.URL, url);
	}

	/// Returns an `ISVGTypes.Color` that is brightened by the provided percentage
	/// @param source The `ISVGTypes.Color` to brighten
	/// @param percentage The percentage of brightness to apply
	/// @param minimumBump A minimum increase for each channel to ensure dark Colors also brighten
	/// @return color the brightened `ISVGTypes.Color`
	function brightenColor(ISVGTypes.Color memory source, uint8 percentage, uint8 minimumBump) internal pure returns (ISVGTypes.Color memory color) {
		color.red = _brightenComponent(source.red, percentage, minimumBump);
		color.green = _brightenComponent(source.green, percentage, minimumBump);
		color.blue = _brightenComponent(source.blue, percentage, minimumBump);
		color.alpha = source.alpha;
	}

	/// Returns an `ISVGTypes.Color` based on a packed representation of r, g, and b
	/// @notice Useful for code where you want to utilize rgb hex values provided by a designer (e.g. #835525)
	/// @dev Alpha will be hard-coded to 100% opacity
	/// @param packedColor The `ISVGTypes.Color` to convert, e.g. 0x835525
	/// @return color representing the packed input
	function fromPackedColor(uint24 packedColor) internal pure returns (ISVGTypes.Color memory color) {
		color.red = uint8(packedColor >> 16);
		color.green = uint8(packedColor >> 8);
		color.blue = uint8(packedColor);
		color.alpha = 0xFF;
	}

	/// Returns a mixed Color by balancing the ratio of `color1` over `color2`, with a total percentage (for overmixing and undermixing outside the source bounds)
	/// @dev Reverts with `RatioInvalid()` if `ratioPercentage` is > 100
	/// @param color1 The first `ISVGTypes.Color` to mix
	/// @param color2 The second `ISVGTypes.Color` to mix
	/// @param ratioPercentage The percentage ratio of `color1` over `color2` (e.g. 60 = 60% first, 40% second)
	/// @param totalPercentage The total percentage after mixing (for overmixing and undermixing outside the input colors)
	/// @return color representing the result of the mixture
	function mixColors(ISVGTypes.Color memory color1, ISVGTypes.Color memory color2, uint8 ratioPercentage, uint8 totalPercentage) internal pure returns (ISVGTypes.Color memory color) {
		if (ratioPercentage > 100) revert RatioInvalid();
		color.red = _mixComponents(color1.red, color2.red, ratioPercentage, totalPercentage);
		color.green = _mixComponents(color1.green, color2.green, ratioPercentage, totalPercentage);
		color.blue = _mixComponents(color1.blue, color2.blue, ratioPercentage, totalPercentage);
		color.alpha = _mixComponents(color1.alpha, color2.alpha, ratioPercentage, totalPercentage);
	}

	/// Returns a proportionally-randomized Color between the start and stop colors using a random Color seed
	/// @dev Each component (r,g,b) will move proportionally together in the direction from start to stop
	/// @param start The starting bound of the `ISVGTypes.Color` to randomize
	/// @param stop The stopping bound of the `ISVGTypes.Color` to randomize
	/// @param random An `ISVGTypes.Color` to use as a seed for randomization
	/// @return color representing the result of the randomization
	function randomizeColors(ISVGTypes.Color memory start, ISVGTypes.Color memory stop, ISVGTypes.Color memory random) internal pure returns (ISVGTypes.Color memory color) {
		unchecked { // `percent` calculation is always within uint8 because of % 101
			uint8 percent = uint8((1320 * (uint(random.red) + uint(random.green) + uint(random.blue)) / 10000) % 101); // Range is from 0-100
			color.red = _randomizeComponent(start.red, stop.red, random.red, percent);
			color.green = _randomizeComponent(start.green, stop.green, random.green, percent);
			color.blue = _randomizeComponent(start.blue, stop.blue, random.blue, percent);
			color.alpha = 0xFF;
		}
	}

	function _attribute(string memory name, string memory contents) private pure returns (string memory) {
		return string.concat(" ", name, "='", contents, "'");
	}

	function _brightenComponent(uint8 component, uint8 percentage, uint8 minimumBump) private pure returns (uint8 result) {
		unchecked { // `brightenedComponent` is always >= `wideComponent` because of the +100
			uint wideComponent = uint(component);
			uint brightenedComponent = wideComponent * (uint(percentage) + 100) / 100;
			uint wideMinimumBump = uint(minimumBump);
			if (brightenedComponent - wideComponent < wideMinimumBump) {
				brightenedComponent = wideComponent + wideMinimumBump;
			}
			if (brightenedComponent > 0xFF) {
				result = 0xFF; // Clamp to 8 bits
			} else {
				result = uint8(brightenedComponent);
			}
		}
	}

	function _colorValue(ISVGTypes.ColorAttributeKind attributeKind, string memory contents) private pure returns (string memory) {
		return string.concat(attributeKind == ISVGTypes.ColorAttributeKind.RGB ? "rgb(" : "url(#", contents, ")");
	}

	function _mixComponents(uint8 component1, uint8 component2, uint8 ratioPercentage, uint8 totalPercentage) private pure returns (uint8 component) {
		unchecked { // `ratioPercentage` is <= 100 because of the check in mixColors()
			uint mixedComponent = (uint(component1) * ratioPercentage + uint(component2) * (100 - uint(ratioPercentage))) * uint(totalPercentage) / 10000;
			if (mixedComponent > 0xFF) {
				component = 0xFF; // Clamp to 8 bits
			} else {
				component = uint8(mixedComponent);
			}
		}
	}

	function _randomizeComponent(uint8 start, uint8 stop, uint8 random, uint8 percent) private pure returns (uint8 component) {
		if (start == stop) {
			component = start;
		} else { // This is the standard case
			(uint8 floor, uint8 ceiling) = start < stop ? (start, stop) : (stop, start);
			unchecked { // `ceiling` is always > `floor`, thus -1 from `random` is ok
				component = floor + uint8(uint(ceiling - (random & 0x01) - floor) * uint(percent) / 100);
			}
		}
	}
}
