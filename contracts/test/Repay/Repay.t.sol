// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../SetUp.sol";
import "./InternalRepayTestCommon.sol";

contract TestRepay is SetUp, InternalRepayTestCommon {
    using RayMath for Ray;
    using RayMath for uint256;

    function testSimpleRepay() public {
        Protocol storage proto = protocolStorage();
        vm.warp(365 days);
        uint256[] memory uint256Array = new uint256[](1);
        uint256Array[0] = 1;
        nft.transferFrom(address(this), address(kairos), 1);
        Loan memory loan = getDefaultLoan();
        loan.borrower = address(this);
        store(loan, 1);
        uint256 toRepay = uint256(1 ether * 2 weeks).mul(proto.tranche[0]) + 1 ether;
        vm.startPrank(signer);
        money.mint(toRepay);
        money.approve(address(kairos), toRepay);
        kairos.repay(uint256Array);
        assertEq(nft.balanceOf(address(this)), 1);
        assertEq(money.balanceOf(signer), 0);
    }

    // TODO: BUG RELOU
    function testMultipleRepay() public {
        Protocol storage proto = protocolStorage();
        _setApprovalForAll(address(this), signer, true);
        vm.warp(365 days);
        uint256[] memory uint256Array = new uint256[](2);
        uint256Array[0] = 1;
        uint256Array[1] = 2;
        nft.mintOne();
        nft2.mintOne();
        nft.transferFrom(address(this), address(kairos), 1);
        nft2.transferFrom(address(this), address(kairos), 1);
        Loan memory loan1 = getDefaultLoan();
        Loan memory loan2 = getDefaultLoan();
        loan1.borrower = address(this);
        loan2.borrower = address(this);
        store(loan1, 1);
        store(loan2, 2);
        uint256 toRepay = (uint256(1 ether * 2 weeks).mul(proto.tranche[0]) + 1 ether) * 3;
        vm.prank(msg.sender);
        money.mint(toRepay);

        console.log(money.balanceOf(msg.sender));
        money.approve(address(kairos), toRepay);
        nft.approve(address(kairos), 1);

        nft2.approve(msg.sender, 2);
        kairos.repay(uint256Array);
        assertEq(nft.balanceOf(address(this)), 1);
        assertEq(money.balanceOf(signer), 0);
    }
}
