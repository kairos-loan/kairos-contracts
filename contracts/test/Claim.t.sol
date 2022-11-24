// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./Commons/External.sol";

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

    function claimN(uint8 nbOfClaims) internal {
        uint256[] memory positionIds = new uint256[](nbOfClaims);

        for (uint8 i; i < nbOfClaims; i++) {
            positionIds[i] = i + 1;
            Loan memory loan = getLoan();
            loan.supplyPositionIndex = i + 1;
            loan.payment.paid = 1 ether;
            store(loan, i + 1);
            Provision memory provision = getProvision();
            provision.loanId = i + 1;
            mintPosition(signer, provision);
            money.transfer(address(kairos), 1 ether);
        }

        vm.prank(signer);
        kairos.claim(positionIds);

        assertEq(money.balanceOf(address(kairos)), 0);
        assertEq(money.balanceOf(address(signer)), nbOfClaims * 1 ether);

        for (uint8 i; i < nbOfClaims; i++) {
            vm.expectRevert(ERC721InvalidTokenId.selector);
            kairos.ownerOf(i);
        }
    }

    function claimNAsBorrower(uint8 nbOfClaims) internal {
        uint256[] memory loanIds = new uint256[](nbOfClaims);

        for (uint8 i; i < nbOfClaims; i++) {
            loanIds[i] = i + 1;
            Loan memory loan = getLoan();
            loan.payment.paid = 1 ether;
            loan.shareLent = ONE.div(2);
            loan.payment.liquidated = true;

            store(loan, i + 1);
            money.transfer(address(kairos), 1 ether / 2);
        }

        vm.prank(signer);
        kairos.claimAsBorrower(loanIds);

        assertEq(money.balanceOf(address(kairos)), 0);
        assertEq(money.balanceOf(address(signer)), (nbOfClaims * 1 ether) / 2);
    }
}
