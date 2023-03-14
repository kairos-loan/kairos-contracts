// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {IClaimEmitter} from "../../src/interface/IClaimFacet.sol";

// solhint-disable-next-line max-line-length
import {BorrowerAlreadyClaimed, LoanNotRepaidOrLiquidatedYet, NotBorrowerOfTheLoan} from "../../src/DataStructure/Errors.sol";
import {ERC721InvalidTokenId} from "../../src/DataStructure/ERC721Errors.sol";
import {External} from "../Commons/External.sol";
import {Loan, Provision} from "../../src/DataStructure/Storage.sol";
import {ONE} from "../../src/DataStructure/Global.sol";
import {Ray} from "../../src/DataStructure/Objects.sol";
import {RayMath} from "../../src/utils/RayMath.sol";

contract TestClaim is External, IClaimEmitter {
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
        store(loan, 1);
        loanIds[0] = 1;
        vm.prank(BORROWER);
        vm.expectRevert(abi.encodeWithSelector(BorrowerAlreadyClaimed.selector, loanIds[0]));
        kairos.claimAsBorrower(loanIds);
    }

    function testShouldRevertOnClaimingNonLiquidatedLoanAsBorrower() public {
        mintLoan();
        vm.prank(BORROWER);
        vm.expectRevert(abi.encodeWithSelector(LoanNotRepaidOrLiquidatedYet.selector, 1));
        kairos.claimAsBorrower(oneInArray);
    }

    function testClaimOfNotLiquidatedLoan() public {
        Loan memory loan = getLoan();
        store(loan, 1);

        Provision memory provision = getProvision();
        mintPosition(signer, provision);

        vm.prank(signer);
        vm.expectRevert(abi.encodeWithSelector(LoanNotRepaidOrLiquidatedYet.selector, 1));
        kairos.claim(oneInArray);
    }

    function claimN(uint8 nbOfClaims) internal {
        uint256[] memory positionIds = new uint256[](nbOfClaims);
        uint256 balanceBefore = money.balanceOf(signer);

        for (uint256 i = 0; i < nbOfClaims; i++) {
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
        for (uint256 i = 0; i < nbOfClaims; i++) {
            vm.expectEmit(true, true, true, true);
            emit Claim(signer, 1 ether, i + 1);
        }

        vm.prank(signer);
        kairos.claim(positionIds);

        assertEq(money.balanceOf(address(kairos)), 0, "kairos balance invalid");
        assertEq(
            money.balanceOf(address(signer)),
            balanceBefore + nbOfClaims * 1 ether,
            "signer balance invalid"
        );

        for (uint256 i = 0; i < nbOfClaims; i++) {
            vm.expectRevert(ERC721InvalidTokenId.selector);
            kairos.ownerOf(i);
        }
    }

    function claimNAsBorrower(uint256 nbOfClaims) internal {
        uint256[] memory loanIds = new uint256[](nbOfClaims);

        for (uint256 i = 0; i < nbOfClaims; i++) {
            loanIds[i] = i + 1;
            Loan memory loan = getLoan();
            loan.payment.paid = 1 ether;
            loan.shareLent = ONE.div(2);
            loan.payment.liquidated = true;

            store(loan, i + 1);
            money.mint(1 ether / 2, address(kairos));
        }
        for (uint256 i = 0; i < nbOfClaims; i++) {
            vm.expectEmit(true, true, true, true);
            emit Claim(BORROWER, 1 ether / 2, i + 1);
        }

        vm.prank(BORROWER);
        kairos.claimAsBorrower(loanIds);

        assertEq(money.balanceOf(address(kairos)), 0);
        assertEq(money.balanceOf(address(BORROWER)), (nbOfClaims * 1 ether) / 2);
    }
}
