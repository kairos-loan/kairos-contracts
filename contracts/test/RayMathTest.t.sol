pragma solidity ^0.8.0;

import "../utils/RayMath.sol";
import "./TestCommons.sol";
import "./SetUp.sol";
import "forge-std/Test.sol";
import "./SafeMath.sol";


contract RayMathTest is TestCommons, SetUp {
    using RayMath for Ray;
    using RayMath for uint256;

    function testRayMathAdd(uint a, uint b) public  {

        Ray aRay = RayMath.add( Ray.wrap(a),Ray.wrap(1));
        Ray bRay = RayMath.add(Ray.wrap(b),Ray.wrap(1));

        Ray TotRay = RayMath.add(bRay,aRay);
        Ray totUint = Ray.wrap(a+b+ Ray.unwrap(RayMath.mul(Ray.wrap(1),2)));

        assertEq(TotRay,totUint);
    }

    function testRayMathMul(Ray a) public {
        Ray a1 = RayMath.mul(a, 2);
        Ray a2 = RayMath.add(a,a);
        assertEq(a1,a2);
    }

    function testRayDivSub(Ray a) public {
        Ray a1 = RayMath.div(a, 2);
        Ray a2 = RayMath.sub(a,a1);
        assertEq(a1,a2);
    }

    function testRayGt(uint a, uint b) public {
        if(a>b){
            bool r =RayMath.gt(Ray.wrap(a), Ray.wrap(b));
            assertEq(r, true);
        }
    }
    function testRayGte(uint a, uint b) public {
        if(a>b || a==b){
            bool r =RayMath.gte(Ray.wrap(a), Ray.wrap(b));
            assertEq(r, true);
        }
    }

    function testRaylt(uint a, uint b) public {
        if(a<b){
            bool r =RayMath.lt(Ray.wrap(a), Ray.wrap(b));
            assertEq(r, true);
        }
    }
    function testRayEq(uint a, uint b) public {
        if(a==b){
            bool r =RayMath.eq(Ray.wrap(a), Ray.wrap(b));
            assertEq(r, true);
        }
    }
}
