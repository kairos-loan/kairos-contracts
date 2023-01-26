// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ComplexBorrowData, ComplexBorrowPreExecFuncs} from "./PreExecFuncs.sol";
import {BorrowArgs, Ray} from "../../../src/DataStructure/Objects.sol";
import {RequestedAmountTooHigh} from "../../../src/DataStructure/Errors.sol";
import {RayMath} from "../../../src/utils/RayMath.sol";

contract TestComplexBorrowRepaid is ComplexBorrowPreExecFuncs {
    using RayMath for Ray;
    using RayMath for uint256;

    // should borrow the maximum from 1 NFT from 2 offers of different suppliers having different LTV
    function testComplexBorrowRepaid() public {
        ComplexBorrowData memory d; // d as data
        d.m1InitialBalance = money.balanceOf(address(this));

        prepareSigners();
        d = initOffers(d, 2 ether, 3 ether);
        d = initOfferArgs(d, 1 ether, (3 ether) / 2);
        d = initBorrowArgs(d);
        execBorrowAndCheckSupplyPos(d);
        skip(2 days);
        execRepay();
        execClaim();
    }

    // should borrow over the maximum from 1 NFT from 2 offers
    function testComplexBorrowRepaidTooHigh() public {
        ComplexBorrowData memory d;
        d.m1InitialBalance = money.balanceOf(address(this));

        prepareSigners();
        d = initOffers(d, 2 ether, 3 ether);
        d = initOfferArgs(d, 1 ether, 2 ether);
        d = initBorrowArgs(d);
        vm.expectRevert(abi.encodeWithSelector(RequestedAmountTooHigh.selector, 2 ether, (3 ether) / 2));
        execBorrowAndCheckSupplyPos(d);
    }

    function execBorrowAndCheckSupplyPos(ComplexBorrowData memory d) private {
        BorrowArgs[] memory batchbargs = new BorrowArgs[](1);
        batchbargs[0] = d.bargs;

        vm.prank(BORROWER);
        kairos.borrow(batchbargs);
    }

    function execRepay() private {
        vm.prank(BORROWER);
        uint256[] memory loanIds = new uint256[](1);
        loanIds[0] = 1;
        kairos.repay(loanIds);
    }

    function execClaim() private {
        uint256[] memory supplyPositionIds = new uint256[](1);

        vm.prank(signer);
        supplyPositionIds[0] = 1;
        kairos.claim(supplyPositionIds);

        vm.prank(signer2);
        supplyPositionIds[0] = 2;
        kairos.claim(supplyPositionIds);
    }
}
