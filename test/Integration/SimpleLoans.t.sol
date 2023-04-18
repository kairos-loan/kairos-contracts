// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

// solhint-disable no-console
import {console} from "forge-std/console.sol";

import {External} from "../Commons/External.sol";
import {OfferArg, Ray, Offer, BuyArg} from "../../src/DataStructure/Objects.sol";
import {RayMath} from "../../src/utils/RayMath.sol";

/// @notice tests of entire loan lifecycles
contract TestIntegration is External {
    using RayMath for Ray;
    using RayMath for uint256;

    function testSimpleLoan() public {
        // signer is the supplier
        vm.prank(OWNER);
        kairos.setMinOfferCost(money, 1);
        getFlooz(BORROWER, money, 10 ether);
        uint256 borrowerInitialBalance = money.balanceOf(BORROWER);
        uint256 amountBorrowed = 1 ether;
        getFlooz(signer, money, amountBorrowed);
        uint256 signerInitialBalance = money.balanceOf(signer);
        OfferArg[] memory offerArgs = getOfferArgs();
        uint256 tokenId = nft.mintOneTo(BORROWER);
        vm.prank(BORROWER);
        uint256 gasBeforeBorrow = gasleft();
        nft.safeTransferFrom(BORROWER, address(kairos), tokenId, abi.encode(offerArgs));
        uint256 gasAfterBorrow = gasleft();
        console.log("gas used for borrow", gasBeforeBorrow - gasAfterBorrow);
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
        uint256 gasBeforeClaim = gasleft();
        kairos.claim(oneInArray);
        uint256 gasAfterClaim = gasleft();
        console.log("gas used for claim", gasBeforeClaim - gasAfterClaim);
        assertEq(money.balanceOf(signer), signerInitialBalance + toRepay - amountBorrowed);
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
        buyArg[0] = BuyArg({loanId: 1, to: signer2, maxPrice: 100 ether});
        vm.prank(signer2);
        kairos.buy(buyArg);
        vm.prank(signer);
        kairos.claim(oneInArray);
        assertEq(money.balanceOf(signer), signerInitialBalance);
    }
}
