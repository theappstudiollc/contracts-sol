// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../utils/SVG.sol";

/// @title Mock class for unit testing SVG.sol
contract SVGMock {

    /// Returns a named element based on the supplied attributes and contents
    function createElement(string memory name, string memory attributes, string memory contents) public pure returns (string memory) {
        return string(SVG.createElement(name, bytes(attributes), bytes(contents)));
    }
    
    /// Returns the root SVG attributes based on the supplied width and height
    function svgAttributes(uint256 width, uint256 height) public pure returns (string memory) {
        return string(SVG.svgAttributes(width, height));
    }

    /// Returns an RGB string suitable as an attribute for SVG elements based on the supplied Color and ColorType
    /// @dev includes necessary leading space for all types _except_ None
    function colorAttribute(ISVGTypes.ColorAttributeType colorType, string memory colorValue) public pure returns (string memory) {
        return string(SVG.colorAttribute(colorType, bytes(colorValue)));
    }

    /// Returns an RGB color attribute value
    function colorAttributeRGBValue(ISVGTypes.Color memory color) public pure returns (string memory) {
        return string(SVG.colorAttributeRGBValue(color));
    }

    /// Returns a URL color attribute value
    function colorAttributeURLValue(string memory url) public pure returns (string memory) {
        return string(SVG.colorAttributeURLValue(bytes(url)));
    }

    /// Returns a Color that is brightened by the provided percentage
    function brightenColor(ISVGTypes.Color memory source, uint32 percentage, uint8 minimumBump) public pure returns (ISVGTypes.Color memory color) {
        return SVG.brightenColor(source, percentage, minimumBump);
    }

    /// Returns an ISVGTypes.Color based on a packed representation of r, g, and b
    function fromPackedColor(uint24 packedColor) public pure returns (ISVGTypes.Color memory color) {
        return SVG.fromPackedColor(packedColor);
    }

    /// Returns a mixed Color by balancing the ratio between `color1` and `color2`, with a total percentage (for overmixing and undermixing outside the source bounds)
    function mixColors(ISVGTypes.Color memory color1, ISVGTypes.Color memory color2, uint32 ratioPercentage, uint32 totalPercentage) public pure returns (ISVGTypes.Color memory color) {
        return SVG.mixColors(color1, color2, ratioPercentage, totalPercentage);
    }

    /// Returns a proportionally-randomized Color between the floor and ceiling colors using a random Color seed
    function randomizeColors(ISVGTypes.Color memory floor, ISVGTypes.Color memory ceiling, ISVGTypes.Color memory random) public pure returns (ISVGTypes.Color memory color) {
        return SVG.randomizeColors(floor, ceiling, random);
    }
}
