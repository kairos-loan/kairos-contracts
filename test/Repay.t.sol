// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {External} from "./Commons/External.sol";
import {Loan, Provision} from "../src/DataStructure/Storage.sol";
import {BuyArg, Ray} from "../src/DataStructure/Objects.sol";
import {RayMath} from "../src/utils/RayMath.sol";
import {LoanAlreadyRepaid} from "../src/DataStructure/Errors.sol";

contract TestRepay is External {
    using RayMath for Ray;
    using RayMath for uint256;

    function testSimpleRepay() public {
        repayNTimes(1);
    }

    function testMultipleRepays() public {
        repayNTimes(12);
    }

    function testRepayAlreadyRepaid() public {
        uint256[] memory loanIds = new uint256[](1);
        loanIds[0] = 1;
        repayNTimes(1);
        vm.expectRevert(abi.encodeWithSelector(LoanAlreadyRepaid.selector, 1));
        kairos.repay(loanIds);
    }

    // should try to repay a loan whose collat has been claimed by the single supplir, and share of liquidation claimed by the borrower
    function testRepayWhenBorrowerClaimed() public {
        Loan memory loan = getLoan();
        uint256[] memory loanIds = oneInArray;
        BuyArg[] memory args = storeAndGetArgs(loan);
        args[0].positionIds = oneInArray;
        Provision memory provision = getProvision();
        mintPosition(signer, provision);
        nft.mintOneTo(address(kairos));

        skip(2 weeks);

        vm.prank(signer);
        kairos.buy(args);

        vm.prank(BORROWER);
        kairos.claimAsBorrower(loanIds);

        Loan memory storedLoan = kairos.getLoan(1);
        assertEq(storedLoan.payment.paid, 0);
        assertEq(storedLoan.payment.borrowerClaimed, true);

        vm.expectRevert(abi.encodeWithSelector(LoanAlreadyRepaid.selector, 1));
        kairos.repay(loanIds);
    }

    function repayNTimes(uint8 nbOfRepays) internal {
        uint256[] memory loanIds = new uint256[](nbOfRepays);
        uint256 balanceBorrowerBefore;
        uint256 toRepay = nbOfRepays * (uint256(1 ether * 2 weeks).mul(getTranche(0)) + 1 ether);
        uint256 currTokenId;

        for (uint8 i = 0; i < nbOfRepays; i++) {
            loanIds[i] = i + 1;
            currTokenId = nft.mintOneTo(address(kairos));
            Loan memory loan = getLoan();
            loan.startDate = block.timestamp;
            loan.collateral.id = currTokenId;
            store(loan, i + 1);
        }

        skip(2 weeks);

        getFlooz(BORROWER, money);
        balanceBorrowerBefore = money.balanceOf(BORROWER);

        vm.prank(BORROWER);
        kairos.repay(loanIds);

        assertEq(nft.balanceOf(BORROWER), nbOfRepays);
        assertEq(money.balanceOf(BORROWER), balanceBorrowerBefore - toRepay);
    }
}
