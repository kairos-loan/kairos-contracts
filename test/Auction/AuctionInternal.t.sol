// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Ray} from "../../src/DataStructure/Objects.sol";
import {Protocol} from "../../src/DataStructure/Storage.sol";
import {ONE, protocolStorage} from "../../src/DataStructure/Global.sol";
import {Internal} from "../Commons/Internal.sol";
import {RayMath} from "../../src/utils/RayMath.sol";

contract TestAuction is Internal {
    using RayMath for Ray;
    using RayMath for uint256;

    uint256 private testLoanId = 0;
    uint256 private lent;

    function setUp() public {
        Protocol storage proto = protocolStorage();

        proto.loan[testLoanId] = getLoan();
        lent = proto.loan[testLoanId].lent;
    }

    function testInitialPrice() public {
        setTimeElapsed(1);
        // 2999988425925925925 ~= lent.mul(protocolStorage().auction.priceFactor
        assertEq(price(testLoanId), 2999988425925925925); // calculated price after 1 sec
    }

    function testPrice() public {
        Protocol storage proto = protocolStorage();

        uint256 initialPrice = lent.mul(proto.auction.priceFactor);

        setTimeElapsed(proto.auction.duration / 2);
        assertEq(price(testLoanId), initialPrice / 2);

        setTimeElapsed(proto.auction.duration / 3);
        assertEq(price(testLoanId), (initialPrice / 3) * 2);
    }

    function testFinalPrice() public {
        Protocol storage proto = protocolStorage();

        setTimeElapsed(proto.auction.duration);
        assertEq(price(testLoanId), 0 ether);

        setTimeElapsed(proto.auction.duration + 1);
        assertEq(price(testLoanId), 0 ether);

        setTimeElapsed(proto.auction.duration + 2 weeks);
        assertEq(price(testLoanId), 0 ether);
    }

    function setTimeElapsed(uint256 timeElapsed) internal {
        protocolStorage().loan[testLoanId].endDate = block.timestamp - timeElapsed;
    }
}
