// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {BorrowData, SingleCollatPreExecFuncs} from "./PreExecFuncs.sol";
import {BorrowArgs, Ray} from "../../../src/DataStructure/Objects.sol";
import {RequestedAmountTooHigh} from "../../../src/DataStructure/Errors.sol";
import {RayMath} from "../../../src/utils/RayMath.sol";

contract TestComplexSingleCollateral is SingleCollatPreExecFuncs {
    using RayMath for Ray;
    using RayMath for uint256;

    uint256 private lentFromSigner1;
    uint256 private lentFromSigner2;
    uint256 private totalLent;
    uint256 private initialBalance = 10 ether;
    uint256 private duration = 20 days;

    // should borrow the maximum amount from 1 NFT from 2 offers of different suppliers having different LTV
    function testComplexSingleCollateral() public {
        lentFromSigner1 = 1 ether;
        lentFromSigner2 = 3 ether / 2;
        totalLent = lentFromSigner1 + lentFromSigner2;
        BorrowData memory d; // d as data
        prepareSigners(10 ether, 10 ether, 10 ether);
        d = initOffers(d, 2 ether, 3 ether);
        d = initOfferArgs(d, lentFromSigner1, lentFromSigner2);
        d = initBorrowArgs(d);
        execBorrow(d);
        skip(duration);
        checkBalancesAfterBorrow();
        uint256 interestsToRepay = execRepay();
        checkBalancesAfterRepay(interestsToRepay);
        execClaim();
        checkBalancesAfterClaim(interestsToRepay);
    }

    // should borrow over the maximum from 1 NFT from 2 offers
    function testComplexSingleCollateralOverMax() public {
        BorrowData memory d;
        prepareSigners(10 ether, 10 ether, 10 ether);
        d = initOffers(d, 2 ether, 3 ether);
        d = initOfferArgs(d, 1 ether, 2 ether);
        d = initBorrowArgs(d);
        vm.expectRevert(
            abi.encodeWithSelector(RequestedAmountTooHigh.selector, 2 ether, 3 ether / 2, d.signer2Offer)
        );
        execBorrow(d);
    }

    // should borrow under the maximum from 1 NFT from 2 offers. Borrower will have a share
    function testComplexSingleCollateralUnderMax() public {
        lentFromSigner1 = 1 ether;
        lentFromSigner2 = 1 ether;
        totalLent = lentFromSigner1 + lentFromSigner2;
        BorrowData memory d; // d as data
        prepareSigners(10 ether, 10 ether, 10 ether);
        d = initOffers(d, 2 ether, 3 ether);
        d = initOfferArgs(d, lentFromSigner1, lentFromSigner2);
        d = initBorrowArgs(d);
        execBorrow(d);
        skip(20 days);
        checkBalancesAfterBorrow();
        uint256 interestsToRepay = execRepay();
        checkBalancesAfterRepay(interestsToRepay);
        execClaim();
        checkBalancesAfterClaim(interestsToRepay);
    }

    function execBorrow(BorrowData memory d) private {
        BorrowArgs[] memory batchbargs = new BorrowArgs[](1);
        batchbargs[0] = d.bargs;
        vm.prank(BORROWER);
        kairos.borrow(batchbargs);
    }

    function execRepay() private returns (uint256 interestsToRepay) {
        vm.prank(BORROWER);
        uint256[] memory loanIds = new uint256[](1);
        loanIds[0] = 1;
        kairos.repay(loanIds);
        interestsToRepay = totalLent.mul(kairos.getLoan(1).interestPerSecond.mul(duration));
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

    function checkBalancesAfterBorrow() private {
        assertEq(money.balanceOf(signer), initialBalance - lentFromSigner1, "sig1 bal pb after borrow");
        assertEq(money.balanceOf(signer2), initialBalance - lentFromSigner2, "sig2 bal pb after borrow");
        assertEq(money.balanceOf(BORROWER), initialBalance + totalLent, "borrower bal pb after borrow");
        assertEq(money.balanceOf(address(kairos)), 0);

        assertEq(nft.balanceOf(BORROWER), 0, "borrower nft bal pb after borrow");
        assertEq(nft.balanceOf(address(kairos)), 1, "this nft bal pb after borrow");
    }

    function checkBalancesAfterRepay(uint256 interestsToRepay) private {
        assertEq(money.balanceOf(signer), initialBalance - lentFromSigner1, "sig1 bal pb after repay");
        assertEq(money.balanceOf(signer2), initialBalance - lentFromSigner2, "sig2 bal pb after repay");
        assertEq(money.balanceOf(BORROWER), initialBalance - interestsToRepay, "borrower bal pb after repay");
        assertEq(money.balanceOf(address(kairos)), totalLent + interestsToRepay);

        assertEq(nft.balanceOf(BORROWER), 1, "borrower nft bal pb after repay");
        assertEq(nft.balanceOf(address(kairos)), 0, "this nft bal pb after repay");
    }

    function checkBalancesAfterClaim(uint256 interestsToRepay) private {
        assertEq(
            money.balanceOf(signer),
            initialBalance + interestsToRepay.mul(lentFromSigner1.div(totalLent)),
            "sig1 bal pb after claim"
        );
        assertEq(
            money.balanceOf(signer2),
            initialBalance + interestsToRepay.mul(lentFromSigner2.div(totalLent)),
            "sig2 bal pb after claim"
        );
        assertEq(money.balanceOf(BORROWER), initialBalance - interestsToRepay, "borrower bal pb after claim");
        assertEq(money.balanceOf(address(kairos)), 0);
    }
}
