// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Ray} from "../../src/DataStructure/Objects.sol";
import {ONE, protocolStorage} from "../../src/DataStructure/Global.sol";
import {Internal} from "../Commons/Internal.sol";
import {RayMath} from "../../src/utils/RayMath.sol";

contract TestAuction is Internal {
    using RayMath for Ray;
    using RayMath for uint256;
    uint256 private lent = 1 ether; // amount lent by the lender (not total of loan)

    function testInitialPrice() public {
        uint256 shareDivider = 2;
        assertEq(
            price(lent, ONE.div(shareDivider), 0),
            lent.mul(protocolStorage().auctionPriceFactor) / shareDivider
        ); // totalLent = 2 ether
    }

    function testPrice() public {
        uint256 shareDivider = 3;
        uint256 auctionDurationDivider = 3;
        Ray shareToPay = ONE.div(shareDivider);
        uint256 timeElapsed = protocolStorage().auctionDuration / auctionDurationDivider;
        assertEq(
            price(lent, shareToPay, timeElapsed),
            (lent.mul(protocolStorage().auctionPriceFactor) / shareDivider).mul(
                ONE.sub(ONE.div(auctionDurationDivider))
            )
        ); // totalLent = 3 ether

        auctionDurationDivider = auctionDurationDivider * 2;
        timeElapsed /= 2;
        assertEq(
            price(lent, shareToPay, timeElapsed),
            (lent.mul(protocolStorage().auctionPriceFactor) / shareDivider).mul(
                ONE.sub(ONE.div(auctionDurationDivider))
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
