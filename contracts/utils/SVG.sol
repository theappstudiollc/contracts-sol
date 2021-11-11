// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/ISVGTypes.sol";
import "./SVGErrors.sol";

/// @title SVG image library
library SVG {

    using Strings for uint256;

    /// Returns the root SVG element based on the supplied width, height, and contents
    /// @dev contents is usually generated from abi.encodePacked
    /// @param width The width of the SVG view box
    /// @param height The height of the SVG view box
    /// @param contents The contents of the svg, as bytes
    /// @return a bytes collection representing a root SVG element
    function createSVG(uint256 width, uint256 height, bytes memory contents) internal pure returns (bytes memory) {
        return abi.encodePacked("<svg viewBox='0 0 ", width.toString(), " ", height.toString(), "' xmlns='http://www.w3.org/2000/svg' version='1.1'>", contents, "</svg>");
    }

    /// Returns a `path` SVG element with the provided attributes and contents
    /// @dev If your use-case does not utilize `attributes` and/or `contents`, consider creating custom code for your path element
    /// @param attributes The attributes of the path, as bytes
    /// @param contents The contents of the path, as bytes
    /// @return a bytes collection representing a `path` element
    function createPath(bytes memory attributes, bytes memory contents) internal pure returns (bytes memory) {
        return abi.encodePacked("<path ", attributes, ">", contents, "</path>");
        /* This produces ideal output, but it consumes too many bytes in the contract (consider an assembly version)
        return abi.encodePacked(
            attributes.length == 0 ? "<path" : "<path ", attributes,
            contents.length == 0 ? "/>" : ">", contents, "</path>"
        ); */
    }

    /// Returns an RGB bytes collection suitable as an attribute for SVG elements based on the supplied Color and ColorType
    /// @dev includes necessary leading space for all types _except_ None
    /// @param color The `ISVGTypes.Color` to convert into a string
    /// @param colorType The `ISVGTypes.ColorType` of the desired attribute
    /// @return a bytes collection representing a color attribute in an SVG element
    function colorAttribute(ISVGTypes.Color memory color, ISVGTypes.ColorType colorType) internal pure returns (bytes memory) {
        if (colorType == ISVGTypes.ColorType.Fill) return abi.encodePacked(" fill='rgb(", _rawColor(color), ")'");
        if (colorType == ISVGTypes.ColorType.Stroke) return abi.encodePacked(" stroke='rgb(", _rawColor(color), ")'");
        return abi.encodePacked("rgb(", _rawColor(color), ")"); // Fallback to None
    }

    /// Returns an `ISVGTypes.Color` that is brightened by the provided percentage
    /// @param source The `ISVGTypes.Color` to brighten
    /// @param percentage The percentage of brightness to apply
    /// @param minimumBump A minimum increase for each channel to ensure dark Colors also brighten
    /// @return color the brightened `ISVGTypes.Color`
    function brightenColor(ISVGTypes.Color memory source, uint32 percentage, uint8 minimumBump) internal pure returns (ISVGTypes.Color memory color) {
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
    function mixColors(ISVGTypes.Color memory color1, ISVGTypes.Color memory color2, uint32 ratioPercentage, uint32 totalPercentage) internal pure returns (ISVGTypes.Color memory color) {
        if (ratioPercentage > 100) revert RatioInvalid();
        color.red = _mixComponents(color1.red, color2.red, ratioPercentage, totalPercentage);
        color.green = _mixComponents(color1.green, color2.green, ratioPercentage, totalPercentage);
        color.blue = _mixComponents(color1.blue, color2.blue, ratioPercentage, totalPercentage);
        color.alpha = _mixComponents(color1.alpha, color2.alpha, ratioPercentage, totalPercentage);
    }

    /// Returns a proportionally-randomized Color between the floor and ceiling colors using a random Color seed
    /// @dev This algorithm does not support floor rgb values matching ceiling rgb values (ceiling must be at least +1 higher for each component)
    /// @param floor The lower bound of the `ISVGTypes.Color` to randomize
    /// @param ceiling The upper bound of the `ISVGTypes.Color` to randomize
    /// @param random An `ISVGTypes.Color` to use as a seed for randomization
    /// @return color representing the result of the randomization
    function randomizeColors(ISVGTypes.Color memory floor, ISVGTypes.Color memory ceiling, ISVGTypes.Color memory random) internal pure returns (ISVGTypes.Color memory color) {
        uint16 percent = (uint16(random.red) + uint16(random.green) + uint16(random.blue)) % 101; // Range is from 0-100
        color.red = _randomizeComponent(floor.red, ceiling.red, random.red, percent);
        color.green = _randomizeComponent(floor.green, ceiling.green, random.green, percent);
        color.blue = _randomizeComponent(floor.blue, ceiling.blue, random.blue, percent);
        color.alpha = 0xFF;
    }

    function _brightenComponent(uint8 component, uint32 percentage, uint8 minimumBump) private pure returns (uint8 result) {
        uint32 wideComponent = uint32(component);
        uint32 brightenedComponent = wideComponent * (percentage + 100) / 100;
        uint32 wideMinimumBump = uint32(minimumBump);
        if (brightenedComponent - wideComponent < wideMinimumBump) {
            brightenedComponent = wideComponent + wideMinimumBump;
        }
        if (brightenedComponent > 0xFF) {
            result = 0xFF; // Clamp to 8 bits
        } else {
            result = uint8(brightenedComponent);
        }
    }

    function _mixComponents(uint8 component1, uint8 component2, uint32 ratioPercentage, uint32 totalPercentage) private pure returns (uint8 component) {
        uint32 mixedComponent = (uint32(component1) * ratioPercentage + uint32(component2) * (100 - ratioPercentage)) * totalPercentage / 10000;
        if (mixedComponent > 0xFF) {
            component = 0xFF; // Clamp to 8 bits
        } else {
            component = uint8(mixedComponent);
        }
    }

    function _randomizeComponent(uint8 floor, uint8 ceiling, uint8 random, uint16 percent) private pure returns (uint8 component) {
        component = floor + uint8(uint16(ceiling - (random & 0x01) - floor) * percent / uint16(100));
    }

    function _rawColor(ISVGTypes.Color memory color) private pure returns (bytes memory) {
        return abi.encodePacked(uint256(color.red).toString(), ",", uint256(color.green).toString(), ",", uint256(color.blue).toString());
    }
}
