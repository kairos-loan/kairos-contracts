pragma solidity ^0.8.0;

import "../utils/RayMath.sol";
import "./TestCommons.sol";
import "./SetUp.sol";
import "forge-std/Test.sol";
import "./SafeMath.sol";

contract RayMathTest is TestCommons, SetUp {
    using RayMath for Ray;
    using RayMath for uint256;

    function testRayMathAdd() public {
        uint a = 2030303;
        uint b = 2304084;

        Ray aRay = RayMath.add(Ray.wrap(a), Ray.wrap(1));
        Ray bRay = RayMath.add(Ray.wrap(b), Ray.wrap(1));

        Ray TotRay = RayMath.add(bRay, aRay);
        Ray totUint = Ray.wrap(a + b + Ray.unwrap(RayMath.mul(Ray.wrap(1), 2)));

        assertEq(TotRay, totUint);
    }

    function testRayMathMul() public {
        Ray a = Ray.wrap(2030303);
        Ray a1 = RayMath.mul(a, 2);
        Ray a2 = RayMath.add(a, a);
        assertEq(a1, a2);
    }

    function testRayGt() public {
        uint a = 2030303;
        uint b = 2304084;
        if (a > b) {
            bool r = RayMath.gt(Ray.wrap(a), Ray.wrap(b));
            assertEq(r, true);
        }
    }

    function testRayGte() public {
        uint a = 2030303;
        uint b = 2304084;
        if (a > b || a == b) {
            bool r = RayMath.gte(Ray.wrap(a), Ray.wrap(b));
            assertEq(r, true);
        }
    }

    function testRaylt(uint a, uint b) public {
        if (a < b) {
            bool r = RayMath.lt(Ray.wrap(a), Ray.wrap(b));
            assertEq(r, true);
        }
    }

    function testRayEq(uint a, uint b) public {
        if (a == b) {
            bool r = RayMath.eq(Ray.wrap(a), Ray.wrap(b));
            assertEq(r, true);
        }
    }
}
