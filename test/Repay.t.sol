// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {External} from "./Commons/External.sol";
import {Loan} from "../src/DataStructure/Storage.sol";
import {Ray} from "../src/DataStructure/Objects.sol";
import {RayMath} from "../src/utils/RayMath.sol";

contract TestRepay is External {
    using RayMath for Ray;
    using RayMath for uint256;

    function testSimpleRepay() public {
        repayNTimes(1);
    }

    function testMultipleRepays() public {
        repayNTimes(12);
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
