// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "../DataStructure.sol";

/// @notice Use to manipulate fixed-point unsigned decimals numbers
library WadRayMath {
    /// @notice `a` times `b`
    function mul(Ray memory a, Ray memory b)
        internal
        pure
        returns (Ray memory)
    {
        return Ray({ray: (a.ray * b.ray) / RAY});
    }

    /// @notice `a` divided by `b`
    function div(Ray memory a, Ray memory b)
        internal
        pure
        returns (Ray memory)
    {
        return Ray({ray: (a.ray * RAY) / b.ray});
    }

    /// @notice `a` times `b`
    /// @dev returns a WAD
    function mulByWad(Ray memory a, uint256 b) internal pure returns (uint256) {
        return (a.ray * b) / RAY;
    }

    /// @notice is `a` less than `b`
    function lt(Ray memory a, Ray memory b) internal pure returns (bool) {
        return a.ray < b.ray;
    }

    /// @notice is `a` greater or equal to `b`
    function gte(Ray memory a, Ray memory b) internal pure returns (bool) {
        return a.ray >= b.ray;
    }

    /// @notice `a` divided by `b`
    function divWadByRay(uint256 a, Ray memory b)
        internal
        pure
        returns (Ray memory)
    {
        return Ray({ray: (a * (RAY * RAY)) / (b.ray * WAD)});
    }

    function divToRay(uint256 a, uint256 b) internal pure returns (Ray memory) {
        return Ray({ray: (a * RAY) / b});
    }
}
