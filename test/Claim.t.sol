// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {BorrowerAlreadyClaimed, NotBorrowerOfTheLoan} from "../src/DataStructure/Errors.sol";
import {ERC721InvalidTokenId} from "../src/DataStructure/ERC721Errors.sol";
import {External} from "./Commons/External.sol";
import {Loan, Provision} from "../src/DataStructure/Storage.sol";
import {ONE} from "../src/DataStructure/Global.sol";
import {Ray} from "../src/DataStructure/Objects.sol";
import {RayMath} from "../src/utils/RayMath.sol";

contract TestClaim is External {
    using RayMath for Ray;

    function testSimpleClaim() public {
        claimN(1);
    }

    function testClaims() public {
        claimN(12);
    }

    function testSimpleClaimAsBorrower() public {
        claimNAsBorrower(1);
    }

    function testClaimsAsBorrower() public {
        claimNAsBorrower(12);
    }

    function testNotBorrowerOfTheLoan() public {
        uint256[] memory loanIds = new uint256[](1);

        Loan memory loan = getLoan();
        store(loan, 1);
        loanIds[0] = 1;
        vm.prank(signer2);
        vm.expectRevert(abi.encodeWithSelector(NotBorrowerOfTheLoan.selector, loanIds[0]));
        kairos.claimAsBorrower(loanIds);
    }

    function testBorrowerAlreadyClaimed() public {
        uint256[] memory loanIds = new uint256[](1);

        Loan memory loan = getLoan();
        loan.payment.borrowerClaimed = true;
        loan.payment.borrowerBought = true;
        store(loan, 1);
        loanIds[0] = 1;
        vm.prank(BORROWER);
        vm.expectRevert(abi.encodeWithSelector(BorrowerAlreadyClaimed.selector, loanIds[0]));
        kairos.claimAsBorrower(loanIds);
    }

    function claimN(uint8 nbOfClaims) internal {
        uint256[] memory positionIds = new uint256[](nbOfClaims);
        uint256 balanceBefore;

        for (uint8 i = 0; i < nbOfClaims; i++) {
            positionIds[i] = i + 1;
            Loan memory loan = getLoan();
            loan.supplyPositionIndex = i + 1;
            loan.payment.paid = 1 ether;
            store(loan, i + 1);
            Provision memory provision = getProvision();
            provision.loanId = i + 1;
            mintPosition(signer, provision);
            money.mint(1 ether, address(kairos));
        }

        balanceBefore = money.balanceOf(signer);
        vm.prank(signer);
        kairos.claim(positionIds);

        assertEq(money.balanceOf(address(kairos)), 0, "kairos balance invalid");
        assertEq(
            money.balanceOf(address(signer)),
            balanceBefore + nbOfClaims * 1 ether,
            "signer balance invalid"
        );

        for (uint8 i = 0; i < nbOfClaims; i++) {
            vm.expectRevert(ERC721InvalidTokenId.selector);
            kairos.ownerOf(i);
        }
    }

    function claimNAsBorrower(uint8 nbOfClaims) internal {
        uint256[] memory loanIds = new uint256[](nbOfClaims);

        for (uint8 i = 0; i < nbOfClaims; i++) {
            loanIds[i] = i + 1;
            Loan memory loan = getLoan();
            loan.payment.paid = 1 ether;
            loan.shareLent = ONE.div(2);
            loan.payment.liquidated = true;

            store(loan, i + 1);
            money.mint(1 ether / 2, address(kairos));
        }

        vm.prank(BORROWER);
        kairos.claimAsBorrower(loanIds);

        assertEq(money.balanceOf(address(kairos)), 0);
        assertEq(money.balanceOf(address(BORROWER)), (nbOfClaims * 1 ether) / 2);
    }
}
