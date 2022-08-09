// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "../DataStructure.sol";

/// @notice Use to manipulate fixed-point unsigned decimals numbers
library WadRayMath {
    /// @notice `a` times `b`
    function mul(Ray a, Ray b)
        internal
        pure
        returns (Ray)
    {
        return Ray.wrap(Ray.unwrap(a) * Ray.unwrap(b) / RAY);
    }

    /// @notice `a` divided by `b`
    function div(Ray a, Ray b)
        internal
        pure
        returns (Ray)
    {
        return Ray.wrap((Ray.unwrap(a) * RAY) / Ray.unwrap(b));
    }

    /// @notice `a` times `b`
    /// @dev returns a WAD
    function mulByWad(Ray a, uint256 b) internal pure returns (uint256) {
        return (Ray.unwrap(a) * b) / RAY;
    }

    /// @notice is `a` less than `b`
    function lt(Ray a, Ray b) internal pure returns (bool) {
        return Ray.unwrap(a) < Ray.unwrap(b);
    }

    /// @notice is `a` greater or equal to `b`
    function gte(Ray a, Ray b) internal pure returns (bool) {
        return Ray.unwrap(a) >= Ray.unwrap(b);
    }

    /// @notice `a` divided by `b`
    function divWadByRay(uint256 a, Ray b)
        internal
        pure
        returns (Ray)
    {
        return Ray.wrap((a * (RAY * RAY)) / (Ray.unwrap(b) * WAD));
    }

    function divToRay(uint256 a, uint256 b) internal pure returns (Ray) {
        return Ray.wrap((a * RAY) / b);
    }
}
