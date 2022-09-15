// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./SetUp.sol";

contract TestClaim is SetUp {
    function testSimpleClaim() public {
        uint256[] memory positionIds = new uint256[](1);
        positionIds[0] = 1;
        Loan memory loan = getDefaultLoan();
        loan.repaid = 1 ether;
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
}