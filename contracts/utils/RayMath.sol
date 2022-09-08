// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../DataStructure/Global.sol";

/// @notice Manipulates fixed-point unsigned decimals numbers
/// @dev all uints are considered integers (no wad)
library RayMath {
    // ~~~ calculus ~~~ //

    /// @notice `a` plus `b`
    function add(Ray a, Ray b) internal pure returns(Ray) {
        return Ray.wrap(Ray.unwrap(a) + Ray.unwrap(b));
    }

    /// @notice `a` minus `b`
    function sub(Ray a, Ray b) internal pure returns(Ray) {
        return Ray.wrap(Ray.unwrap(a) - Ray.unwrap(b));
    }

    /// @notice `a` times `b`
    function mul(Ray a, Ray b) internal pure returns (Ray) {
        return Ray.wrap(Ray.unwrap(a) * Ray.unwrap(b) / RAY);
    }

    /// @notice `a` times `b`
    function mul(Ray a, uint256 b) internal pure returns (Ray) {
        return Ray.wrap(Ray.unwrap(a) * b);
    }

    /// @notice `a` times `b`
    function mul(uint256 a, Ray b) internal pure returns(uint256) {
        return a * Ray.unwrap(b) / RAY;
    }

    /// @notice `a` divided by `b`
    function div(Ray a, Ray b) internal pure returns (Ray) {
        return Ray.wrap((Ray.unwrap(a) * RAY) / Ray.unwrap(b));
    }

    /// @notice `a` divided by `b`
    function div(Ray a, uint256 b) internal pure returns (Ray) {
        return Ray.wrap(Ray.unwrap(a) / b);
    }

    /// @notice `a` divided by `b`
    function divToRay(uint256 a, uint256 b) internal pure returns (Ray) {
        return Ray.wrap((a * RAY) / b);
    }

    // ~~~ comparisons ~~~ //

    /// @notice is `a` less than `b`
    function lt(Ray a, Ray b) internal pure returns (bool) {
        return Ray.unwrap(a) < Ray.unwrap(b);
    }

    /// @notice is `a` greater than `b`
    function gt(Ray a, Ray b) internal pure returns (bool) {
        return Ray.unwrap(a) > Ray.unwrap(b);
    }

    /// @notice is `a` greater or equal to `b`
    function gte(Ray a, Ray b) internal pure returns (bool) {
        return Ray.unwrap(a) >= Ray.unwrap(b);
    }

    /// @notice is `a` equal to `b`
    function eq(Ray a, Ray b) internal pure returns(bool) {
        return Ray.unwrap(a) == Ray.unwrap(b);
    }
}
