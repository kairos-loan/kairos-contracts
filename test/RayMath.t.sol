// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {Ray} from "../src/DataStructure/Objects.sol";
import {RAY, ONE, ZERO} from "../src/DataStructure/Global.sol";
import {RayMath} from "../src/utils/RayMath.sol";
import {stdError} from "forge-std/StdError.sol";

contract TestRayMath is Test {
    using RayMath for Ray;
    using RayMath for uint256;

    function testAdd() public {
        Ray a = Ray.wrap(100);
        Ray b = Ray.wrap(200);
        assertEq(Ray.unwrap(a.add(b)), 300);
    }

    function testAddFuzzing(uint256 a, uint256 b) public {
        vm.assume(a < 1e37);
        vm.assume(b < 1e37);
        assertEq(Ray.unwrap(Ray.wrap(a).add(Ray.wrap(b))), a + b);
    }

    function testSub() public {
        Ray a = Ray.wrap(200);
        Ray b = Ray.wrap(100);
        assertEq(Ray.unwrap(a.sub(b)), 100);
    }

    function testSubFuzzing(uint256 a, uint256 b) public {
        vm.assume(a < 1e37);
        vm.assume(b <= a);
        assertEq(Ray.unwrap(Ray.wrap(a).sub(Ray.wrap(b))), a - b);
    }

    function testSubUnderflow() public {
        Ray a = Ray.wrap(100);
        Ray b = Ray.wrap(200);
        vm.expectRevert(stdError.arithmeticError);
        Ray.unwrap(a.sub(b));
    }

    function testMul() public {
        Ray a = Ray.wrap(5e26);
        Ray b = Ray.wrap(3e26);
        assertEq(Ray.unwrap(a.mul(b)), 15e25);

        a = ONE;
        b = ONE;
        assertEq(a.mul(b), ONE);

        a = ZERO;
        b = ONE;
        assertEq(a.mul(b), ZERO);

        a = ONE.mul(3).div(2);
        b = ONE.mul(3).div(2);
        assertEq(Ray.unwrap(a.mul(b)), 225e25);
    }

    function testMulUintRay() public {
        Ray a = Ray.wrap(3e26);
        uint256 b = 2;
        assertEq(Ray.unwrap(a.mul(b)), 6e26);

        a = ONE;
        b = 1;
        assertEq(a.mul(b), ONE);

        a = ZERO;
        b = 1;
        assertEq(a.mul(b), ZERO);

        a = ONE.mul(3).div(2);
        b = 3;
        assertEq(Ray.unwrap(a.mul(b)), 45e26);
    }

    function testDiv() public {
        Ray a = Ray.wrap(6e26);
        Ray b = Ray.wrap(3e26);
        assertEq(Ray.unwrap(a.div(b)), 2e27);

        a = ONE;
        b = ONE;
        assertEq(a.div(b), ONE);

        a = ONE.mul(3).div(2);
        b = ONE.mul(2);
        assertEq(a.div(b), ONE.mul(3).div(4));
        assertEq(a.div(b), Ray.wrap(75e25));
    }

    function testDivUintRay() public {
        Ray a = Ray.wrap(6e26);
        uint256 b = 3;
        assertEq(Ray.unwrap(a.div(b)), 2e26);

        a = ONE;
        b = 1;
        assertEq(a.div(b), ONE);

        a = ONE.mul(3).div(2);
        b = 2;
        assertEq(a.div(b), ONE.mul(3).div(4));
        assertEq(a.div(b), Ray.wrap(75e25));
    }

    function testLt() public {
        Ray a = Ray.wrap(100);
        Ray b = Ray.wrap(200);
        assertTrue(a.lt(b));
        assertFalse(b.lt(a));
    }

    function testGt() public {
        Ray a = Ray.wrap(100);
        Ray b = Ray.wrap(200);
        assertTrue(b.gt(a));
        assertFalse(a.gt(b));
    }

    function testGte() public {
        Ray a = Ray.wrap(100);
        Ray b = Ray.wrap(200);
        assertTrue(b.gte(a));
        assertFalse(a.gte(b));
        assertTrue(a.gte(a));
    }

    function testEq() public {
        Ray a = Ray.wrap(100);
        Ray b = Ray.wrap(100);
        assertTrue(a.eq(b));

        a = Ray.wrap(100);
        b = Ray.wrap(200);
        assertFalse(a.eq(b));
    }

    /// @notice this test shows that the worst case scenario values in the return value calculation of
    ///     AuctionFacet.sol's price(uint256 loanId) method will not overflow
    function testWorstCaseEstimatedValue() public pure {
        // governance won't decide to set the initial price of liquidated NFTs to be over 100x their estimated value
        Ray priceFactor = ONE.mul(100);
        Ray decreasingFactor = ONE; // ONE is the max value of decreasingFactor
        Ray shareLent = ONE.div(100_000_000); // we empirically chose this value as minimum shareLent
        // 1e40 is the max value of loan.lent
        uint256 estimatedValue = uint256(1e40).div(shareLent);
        estimatedValue.mul(priceFactor).mul(decreasingFactor);
    }

    function assertEq(Ray a, Ray b) private {
        assertTrue(a.eq(b));
    }
}
