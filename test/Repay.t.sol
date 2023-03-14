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

    function testShouldNotBeAbleToRepayALiquidatedLoan() public {
        Loan memory loan = getLoan();
        loan.payment.liquidated = true;
        nft.mintOneTo(address(kairos));
        mintLoan(loan);
        getFlooz(BORROWER, money);
        vm.prank(BORROWER);
        vm.expectRevert(abi.encodeWithSelector(LoanAlreadyRepaid.selector, 1));
        kairos.repay(oneInArray);
    }

    function testRepayAlreadyRepaid() public {
        repayNTimes(1);
        vm.expectRevert(abi.encodeWithSelector(LoanAlreadyRepaid.selector, 1));
        kairos.repay(oneInArray);
    }

    function repayNTimes(uint8 nbOfRepays) internal {
        uint256[] memory loanIds = new uint256[](nbOfRepays);
        uint256 balanceBorrowerBefore;
        uint256 toRepay = nbOfRepays * (uint256(1 ether * 2 weeks).mul(getTranche(0)) + 1 ether);
        uint256 currTokenId;

        for (uint256 i = 0; i < nbOfRepays; i++) {
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
