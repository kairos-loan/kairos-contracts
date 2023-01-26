// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ComplexBorrowData, ComplexBorrowPreExecFuncs} from "./PreExecFuncs.sol";
import {BorrowArgs, NFToken, Ray} from "../../../src/DataStructure/Objects.sol";
import {Loan, Payment, Provision} from "../../../src/DataStructure/Storage.sol";
import {ONE} from "../../../src/DataStructure/Global.sol";
import {RayMath} from "../../../src/utils/RayMath.sol";
import {console2} from "forge-std/console2.sol";

contract TestComplexBorrowRepaid is ComplexBorrowPreExecFuncs {
    using RayMath for Ray;
    using RayMath for uint256;

    // should borrow from 1 NFT from 2 offers of different suppliers
    // NFT 1 : from collec1 with money1 with 2 suppliers
    function testComplexBorrowRepaid() public {
        ComplexBorrowData memory d; // d as data
        d.m1InitialBalance = money.balanceOf(address(this));

        prepareSigners();
        d = initOffers(d);
        d = initOfferArgs(d);
        d = initBorrowArgs(d);
        execBorrowAndCheckSupplyPos(d);
        skip(2 days);
        execRepay();
        execClaim();
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

    function loan1() private view returns (Loan memory) {
        Ray tranche0Rate = kairos.getRateOfTranche(0);
        Payment memory payment;
        uint256[] memory supplyPositionIds1 = new uint256[](2);
        supplyPositionIds1[0] = 1;
        supplyPositionIds1[1] = 2;

        return
            Loan({
                assetLent: money,
                lent: 4 ether,
                shareLent: ONE,
                startDate: block.timestamp,
                endDate: block.timestamp + 1 weeks,
                interestPerSecond: tranche0Rate,
                borrower: BORROWER,
                collateral: NFToken({implem: nft, id: 1}),
                payment: payment,
                supplyPositionIndex: 1,
                nbOfPositions: 2
            });
    }
}
