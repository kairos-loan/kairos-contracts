// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {External} from "./Commons/External.sol";
import {CallerIsNotOwner} from "../src/DataStructure/Errors.sol";
import {Ray} from "../src/DataStructure/Objects.sol";
import {Loan} from "../src/DataStructure/Storage.sol";

contract TestAdmin is External {
    function testOnlyOwner() public {
        vm.expectRevert(abi.encodeWithSelector(CallerIsNotOwner.selector, OWNER));
        kairos.setAuctionDuration(2);
        vm.prank(OWNER);
        kairos.setAuctionDuration(2);

        vm.expectRevert(abi.encodeWithSelector(CallerIsNotOwner.selector, OWNER));
        kairos.setAuctionPriceFactor(Ray.wrap(2));
        vm.prank(OWNER);
        kairos.setAuctionPriceFactor(Ray.wrap(2));

        vm.expectRevert(abi.encodeWithSelector(CallerIsNotOwner.selector, OWNER));
        kairos.createTranche(Ray.wrap(2));
        vm.prank(OWNER);
        kairos.createTranche(Ray.wrap(2));
    }

    function testChangingAuctionParamsModifyOnlyNewLoans() public {
        getFlooz(signer, money, 10_000 ether);
        getJpeg(BORROWER, nft);
        Loan memory loan = getLoan();
        loan.startDate = block.timestamp;
        vm.startPrank(BORROWER);
        // BorrowArg[] memory args = getBorrowArgs();
        // args[0].args[0].offer.startDate = block.timestamp;
        kairos.borrow(getBorrowArgs());
        assertEq(kairos.getLoan(1), loan);
        // vm.stopPrank();
        // vm.startPrank(OWNER);
        // kairos.setAuctionDuration(2);
    }
}
