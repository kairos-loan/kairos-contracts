// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./SetUp.sol";
import "./Repay/InternalRepayTestCommon.sol";

contract TestClaim is SetUp, InternalRepayTestCommon {
    using RayMath for Ray;

    function testSimpleClaim() public {
        uint256[] memory positionIds = new uint256[](1);
        positionIds[0] = 1;
        Loan memory loan = getDefaultLoan();
        loan.payment.paid = 1 ether;
        store(loan, 1);
        mintPosition(signer, getDefaultProvision());
        money.transfer(address(kairos), 1 ether);
        vm.prank(signer);
        kairos.claim(positionIds);
        assertEq(money.balanceOf(address(kairos)), 0);
        assertEq(money.balanceOf(address(signer)), 1 ether);
        vm.expectRevert(ERC721InvalidTokenId.selector);
        assertEq(kairos.ownerOf(1), address(0));
    }

    function testSimpleClaimAsBorrower() public {
        uint256[] memory loanIds = new uint256[](1);
        loanIds[0] = 1;
        Loan memory loan = getDefaultLoan();
        loan.payment.paid = 1 ether;
        loan.shareLent = ONE.div(2);
        loan.payment.liquidated = true;
        store(loan, 1);
        money.transfer(address(kairos), 1 ether / 2);
        vm.prank(signer);
        kairos.claimAsBorrower(loanIds);
        assertEq(money.balanceOf(address(kairos)), 0);
        assertEq(money.balanceOf(address(signer)), 1 ether / 2);
    }

    //Issue ERC721InvalidTokenId()
    function testMultipleClaim() public {
        uint256[] memory positionIds = new uint256[](2);
        positionIds[0] = 1;
        positionIds[1] = 2;
        Loan memory loan1 = getLoan1(1);
        Loan memory loan2 = getLoan2(2);

        loan1.payment.paid = 1 ether;
        store(loan1, 1);

        loan2.payment.paid = 1 ether;
        store(loan2, 2);





        mintPosition(signer, getCustomProvision(1));
        mintPosition(signer, getCustomProvision(2));
        money.transfer(address(kairos), 2 ether);

        vm.prank(signer);
        kairos.claim(positionIds);

        assertEq(money.balanceOf(address(kairos)), 0);
        assertEq(money.balanceOf(address(signer)), 2 ether);
        vm.expectRevert(ERC721InvalidTokenId.selector);
        assertEq(kairos.ownerOf(1), address(0));
    }

    function testMultipleClaimAsBorrower() public {
        uint256[] memory loanIds = new uint256[](2);
        loanIds[0] = 1;
        loanIds[1] = 2;

        Loan memory loan1 = getLoan1(1);
        loan1.payment.paid = 1 ether;
        loan1.shareLent = ONE.div(2);
        loan1.payment.liquidated = true;
        store(loan1, 1);

        Loan memory loan2 = getLoan2(2);
        loan2.payment.paid = 1 ether;
        loan2.shareLent = ONE.div(2);
        loan2.payment.liquidated = true;
        store(loan2, 2);

        money.transfer(address(kairos), 1 ether);
        vm.prank(signer);
        kairos.claimAsBorrower(loanIds);
        assertEq(money.balanceOf(address(kairos)), 0);
        assertEq(money.balanceOf(address(signer)), 1 ether);
    }
}
