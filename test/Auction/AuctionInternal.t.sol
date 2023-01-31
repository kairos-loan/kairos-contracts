// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Ray} from "../../src/DataStructure/Objects.sol";
import {ONE, protocolStorage} from "../../src/DataStructure/Global.sol";
import {Internal} from "../Commons/Internal.sol";
import {RayMath} from "../../src/utils/RayMath.sol";

contract TestAuction is Internal {
    using RayMath for Ray;
    using RayMath for uint256;
    uint256 private lent = 1 ether;

    function testInitialAuctionPrice() public {
        assertEq(price(lent, ONE.div(2), 0), 2 * lent.mul(protocolStorage().auctionPriceFactor)); // totalLent = 2 ether
    }

    function testAuctionPrice() public {
        Ray shareLent = ONE.div(3);
        uint256 timeElapsed = protocolStorage().auctionDuration / 2;
        assertEq(
            price(lent, shareLent, timeElapsed),
            (3 * lent.mul(protocolStorage().auctionPriceFactor)) / 2
        ); // totalLent = 3 ether

        timeElapsed /= 2; // 1/4 of the auction duration
        assertEq(
            price(lent, shareLent, timeElapsed),
            (((3 * lent.mul(protocolStorage().auctionPriceFactor))) * 3) / 4
        );
    }

    function testFinalAuctionPrice() public {
        Ray shareLent = ONE.div(2);
        uint256 timeElapsed = protocolStorage().auctionDuration;
        assertEq(price(lent, shareLent, timeElapsed), 0 ether);

        timeElapsed = protocolStorage().auctionDuration + 1;
        assertEq(price(lent, shareLent, timeElapsed), 0 ether);
    }
}
