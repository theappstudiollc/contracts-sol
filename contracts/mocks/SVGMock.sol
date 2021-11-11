// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../utils/SVG.sol";

/// @title Mock class for unit testing SVG.sol
contract SVGMock {
    
    /// Returns the root SVG element based on the supplied width, height, and contents
    function createSVG(uint256 width, uint256 height, string memory contents) public pure returns (string memory) {
        return string(SVG.createSVG(width, height, bytes(contents)));
    }

    /// Returns a `path` SVG element with the provided attributes and contents
    function createPath(string memory attributes, string memory contents) public pure returns (string memory) {
        return string(SVG.createPath(bytes(attributes), bytes(contents)));
    }

    /// Returns an RGB string suitable as an attribute for SVG elements based on the supplied Color and ColorType
    /// @dev includes necessary leading space for all types _except_ None
    function colorAttribute(ISVGTypes.Color memory color, ISVGTypes.ColorType colorType) public pure returns (string memory) {
        return string(SVG.colorAttribute(color, colorType));
    }

    /// Returns a Color that is brightened by the provided percentage
    function brightenColor(ISVGTypes.Color memory source, uint32 percentage, uint8 minimumBump) public pure returns (ISVGTypes.Color memory color) {
        return SVG.brightenColor(source, percentage, minimumBump);
    }

    /// Returns an ISVGTypes.Color based on a packed representation of r, g, and b
    function fromPackedColor(uint24 packedColor) internal pure returns (ISVGTypes.Color memory color) {
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
