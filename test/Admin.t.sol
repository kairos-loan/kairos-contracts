// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {External} from "./Commons/External.sol";
import {CallerIsNotOwner} from "../src/DataStructure/Errors.sol";
import {Ray, BorrowArg, Offer} from "../src/DataStructure/Objects.sol";
import {ONE} from "../src/DataStructure/Global.sol";
import {Loan} from "../src/DataStructure/Storage.sol";
import {InvalidTranche} from "../src/DataStructure/Errors.sol";
import {RayMath} from "../src/utils/RayMath.sol";

contract TestAdmin is External {
    using RayMath for Ray;

    function testOnlyOwner() public {
        vm.expectRevert(abi.encodeWithSelector(CallerIsNotOwner.selector, OWNER));
        kairos.setAuctionDuration(2);
        vm.prank(OWNER);
        kairos.setAuctionDuration(2);

        vm.expectRevert(abi.encodeWithSelector(CallerIsNotOwner.selector, OWNER));
        kairos.setAuctionPriceFactor(ONE.mul(5).div(2));
        vm.prank(OWNER);
        kairos.setAuctionPriceFactor(ONE.mul(5).div(2));

        vm.expectRevert(abi.encodeWithSelector(CallerIsNotOwner.selector, OWNER));
        kairos.createTranche(Ray.wrap(2));
        vm.prank(OWNER);
        kairos.createTranche(Ray.wrap(2));

        vm.expectRevert(abi.encodeWithSelector(CallerIsNotOwner.selector, OWNER));
        kairos.setMinOfferCost(IERC20(address(15)), 100);
        vm.prank(OWNER);
        kairos.setMinOfferCost(IERC20(address(15)), 100);
    }

    function testChangingAuctionParamsModifyOnlyNewLoans() public {
        getFlooz(signer, money, 10_000 ether);
        getJpeg(BORROWER, nft);
        Loan memory loan = getLoan();
        loan.startDate = block.timestamp;
        BorrowArg[] memory borrowArgs = getBorrowArgs();
        borrowArgs[0].args[0].amount = borrowArgs[0].args[0].offer.loanToValue;
        loan.lent = borrowArgs[0].args[0].amount;
        vm.prank(BORROWER);
        kairos.borrow(borrowArgs);
        assertEq(kairos.getLoan(1), loan, "unexpected loan");

        vm.prank(OWNER);
        kairos.setAuctionDuration(2);
        vm.prank(OWNER);
        kairos.setAuctionPriceFactor(ONE.mul(5).div(2));
        assertEq(kairos.getLoan(1), loan, "unchanged ancient loan fail"); // unchanged ancient loan

        vm.prank(address(kairos));
        nft.transferFrom(address(kairos), BORROWER, 1);
        vm.prank(BORROWER);
        nft.approve(address(kairos), 1);
        vm.prank(BORROWER);
        kairos.borrow(borrowArgs);
        loan.auction.duration = 2;
        loan.auction.priceFactor = ONE.mul(5).div(2);
        loan.supplyPositionIndex = 2;
        assertEq(kairos.getLoan(2), loan, "new changed loan fail"); // for new loan the params have changed
    }

    function testCreateTranche() public {
        Offer memory offer = getOffer();
        getFlooz(signer, money, 10_000 ether);
        getJpeg(BORROWER, nft);

        offer.tranche = 1;
        BorrowArg[] memory borrowArgs = getBorrowArgs(offer);

        vm.prank(BORROWER);
        vm.expectRevert(abi.encodeWithSelector(InvalidTranche.selector, 1));
        kairos.borrow(borrowArgs);

        vm.prank(OWNER);
        kairos.createTranche(Ray.wrap(2));
        vm.prank(BORROWER);
        kairos.borrow(borrowArgs);
        assertEq(kairos.getRateOfTranche(1), Ray.wrap(2));
        assertEq(kairos.getLoan(1).interestPerSecond, Ray.wrap(2));
        (, , , uint256 nbOfTranches) = kairos.getParameters();
        assertEq(nbOfTranches, 2);
    }
}
