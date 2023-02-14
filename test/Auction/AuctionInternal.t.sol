// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Ray} from "../../src/DataStructure/Objects.sol";
import {Protocol} from "../../src/DataStructure/Storage.sol";
import {ONE, protocolStorage} from "../../src/DataStructure/Global.sol";
import {Internal} from "../Commons/Internal.sol";
import {RayMath} from "../../src/utils/RayMath.sol";

contract TestAuction is Internal {
    using RayMath for Ray;
    using RayMath for uint256;

    uint256 private constant LENT = 1 ether;

    function setUp() public override {
        super.setUp();
        testLoan.lent = LENT;
    }

    function testInitialPrice() public {
        Ray shareToPay = ONE.div(2);
        assertEq(
            price(shareToPay, 0, testLoan),
            LENT.mul(protocolStorage().auction.priceFactor).mul(shareToPay)
        );
    }

    function testPrice() public {
        Protocol storage proto = protocolStorage();

        Ray shareToPay = ONE.div(11);
        uint256 auctionDurationDivider = 13;
        uint256 timeElapsed = proto.auction.duration / auctionDurationDivider;
        assertEq(
            price(shareToPay, timeElapsed, testLoan),
            (
                LENT.mul(proto.auction.priceFactor).mul(shareToPay).mul(
                    ONE.sub(timeElapsed.div(proto.auction.duration))
                )
            )
        );

        auctionDurationDivider = auctionDurationDivider * 2;
        timeElapsed /= 2;
        assertEq(
            price(shareToPay, timeElapsed, testLoan),
            (
                LENT.mul(proto.auction.priceFactor).mul(shareToPay).mul(
                    ONE.sub(timeElapsed.div(proto.auction.duration))
                )
            )
        );
    }

    function testFinalPrice() public {
        Protocol storage proto = protocolStorage();

        Ray shareToPay = ONE.div(3);
        uint256 timeElapsed = proto.auction.duration;
        assertEq(price(shareToPay, timeElapsed, testLoan), 0 ether);

        timeElapsed = proto.auction.duration + 1;
        assertEq(price(shareToPay, timeElapsed, testLoan), 0 ether);

        timeElapsed = proto.auction.duration + 2 weeks;
        assertEq(price(shareToPay, timeElapsed, testLoan), 0 ether);
    }
}
