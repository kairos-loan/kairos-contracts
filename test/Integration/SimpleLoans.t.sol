// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {External} from "../Commons/External.sol";
import {OfferArg, Ray, Offer, BuyArg} from "../../src/DataStructure/Objects.sol";
import {RayMath} from "../../src/utils/RayMath.sol";

/// @notice tests of entire loan lifecycles
contract TestIntegration is External {
    using RayMath for Ray;
    using RayMath for uint256;

    function testSimpleLoan() public {
        // signer is the supplier
        getFlooz(BORROWER, money, 10 ether);
        uint256 borrowerInitialBalance = money.balanceOf(BORROWER);
        uint256 amountBorrowed = 1 ether;
        getFlooz(signer, money, amountBorrowed);
        uint256 signerInitialBalance = money.balanceOf(signer);
        OfferArg[] memory offerArgs = getOfferArgs();
        uint256 tokenId = nft.mintOneTo(BORROWER);
        vm.prank(BORROWER);
        nft.safeTransferFrom(BORROWER, address(kairos), tokenId, abi.encode(offerArgs));
        assertEq(
            money.balanceOf(signer),
            signerInitialBalance - amountBorrowed,
            "lender balance incorrect after loan"
        );
        assertEq(money.balanceOf(BORROWER), borrowerInitialBalance + amountBorrowed);
        assertEq(nft.ownerOf(1), address(kairos));
        skip(1 weeks);
        uint256 toRepay = amountBorrowed.mul(getTranche(0).mul(1 weeks)) + amountBorrowed;
        vm.prank(BORROWER);
        money.approve(address(kairos), toRepay);
        vm.prank(BORROWER);
        kairos.repay(oneInArray);
        assertEq(money.balanceOf(BORROWER), borrowerInitialBalance + amountBorrowed - toRepay);
        vm.prank(signer);
        kairos.claim(oneInArray);
        assertEq(money.balanceOf(signer), signerInitialBalance + toRepay - amountBorrowed);
    }

    // solhint-disable-next-line function-max-lines
    function testShouldEnforceMinimalOfferCost() public {
        uint256[] memory oneAndTwoInArray = new uint256[](2);
        oneAndTwoInArray[0] = 1;
        oneAndTwoInArray[1] = 2;
        uint256[] memory twoInArray = oneInArray;
        twoInArray[0] = 2;
        uint256[] memory threeInArray = oneInArray;
        threeInArray[0] = 3;
        getFlooz(BORROWER, money);
        uint256 borrowerInitialBalance = money.balanceOf(BORROWER);
        getFlooz(signer, money);
        uint256 signerInitialBalance = money.balanceOf(signer);
        OfferArg[] memory offerArgs = new OfferArg[](2);
        offerArgs[0] = getOfferArg();
        offerArgs[1] = getOfferArg();
        getJpeg(BORROWER, nft);
        vm.prank(BORROWER);
        nft.setApprovalForAll(address(kairos), true);
        vm.prank(BORROWER);
        kairos.borrow(getBorrowArgs(offerArgs));
        vm.prank(BORROWER);
        kairos.repay(oneInArray);
        assertEq(money.balanceOf(BORROWER), borrowerInitialBalance);
        vm.prank(signer);
        kairos.claim(oneAndTwoInArray);
        assertEq(money.balanceOf(signer), signerInitialBalance);
        vm.prank(OWNER);
        kairos.setMinOfferCost(money, 1 ether);
        offerArgs[0].amount = 1; // borrow only one wei with first offer
        vm.prank(BORROWER);
        kairos.borrow(getBorrowArgs(offerArgs));
        vm.prank(BORROWER);
        kairos.repay(twoInArray);
        vm.prank(signer);
        kairos.claim(threeInArray); // claim only one position from 2 owned
        assertEq(money.balanceOf(BORROWER), borrowerInitialBalance - 2 ether, "borr bal");
        assertEq(money.balanceOf(signer), signerInitialBalance, "signer bal");
        assertEq(money.balanceOf(address(kairos)), 2 ether, "kairos bal");
    }

    function testLenderShouldNotLoseMoneyOnOkayEstimation() public {
        getFlooz(BORROWER, money, 10 ether);
        uint256 amountBorrowed = 1 ether;
        getFlooz(signer, money, amountBorrowed);
        getFlooz(signer2, money, 10 ether);
        uint256 signerInitialBalance = money.balanceOf(signer);
        OfferArg[] memory offerArgs = getOfferArgs();
        uint256 tokenId = nft.mintOneTo(BORROWER);
        vm.prank(BORROWER);
        // what is borrowed is one 10th of the ltv
        nft.safeTransferFrom(BORROWER, address(kairos), tokenId, abi.encode(offerArgs));
        skip(2 weeks + 2 days); // enter auction, skip to price = ltv
        BuyArg[] memory buyArg = new BuyArg[](1);
        buyArg[0] = BuyArg({loanId: 1, to: signer2});
        vm.prank(signer2);
        kairos.buy(buyArg);
        vm.prank(signer);
        kairos.claim(oneInArray);
        assertEq(money.balanceOf(signer), signerInitialBalance);
    }
}
