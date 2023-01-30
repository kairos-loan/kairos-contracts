// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {External} from "../Commons/External.sol";
import {OfferArgs, Ray} from "../../src/DataStructure/Objects.sol";
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
        OfferArgs[] memory offerArgs = getOfferArgs(getOffer());
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
}
