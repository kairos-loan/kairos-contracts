// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Ray} from "../../src/DataStructure/Objects.sol";
import {ONE, protocolStorage} from "../../src/DataStructure/Global.sol";
import {Internal} from "../Commons/Internal.sol";
import {RayMath} from "../../src/utils/RayMath.sol";

contract TestAuction is Internal {
    using RayMath for Ray;
    using RayMath for uint256;
    uint256 private lent = 1 ether; // total amount lent in the loan

    function testInitialPrice() public {
        Ray shareToPay = ONE.div(2);
        assertEq(price(lent, shareToPay, 0), lent.mul(protocolStorage().auctionPriceFactor).mul(shareToPay));
    }

    function testPrice() public {
        Ray shareToPay = ONE.div(11);
        uint256 auctionDurationDivider = 13;
        uint256 timeElapsed = protocolStorage().auctionDuration / auctionDurationDivider;
        assertEq(
            price(lent, shareToPay, timeElapsed),
            (
                lent.mul(protocolStorage().auctionPriceFactor).mul(shareToPay).mul(
                    ONE.sub(timeElapsed.div(protocolStorage().auctionDuration))
                )
            )
        );

        auctionDurationDivider = auctionDurationDivider * 2;
        timeElapsed /= 2;
        assertEq(
            price(lent, shareToPay, timeElapsed),
            (
                lent.mul(protocolStorage().auctionPriceFactor).mul(shareToPay).mul(
                    ONE.sub(timeElapsed.div(protocolStorage().auctionDuration))
                )
            )
        );
    }

    function testFinalPrice() public {
        Ray shareToPay = ONE.div(3);
        uint256 timeElapsed = protocolStorage().auctionDuration;
        assertEq(price(lent, shareToPay, timeElapsed), 0 ether);

        timeElapsed = protocolStorage().auctionDuration + 1;
        assertEq(price(lent, shareToPay, timeElapsed), 0 ether);

        timeElapsed = protocolStorage().auctionDuration + 2 weeks;
        assertEq(price(lent, shareToPay, timeElapsed), 0 ether);
    }
}
