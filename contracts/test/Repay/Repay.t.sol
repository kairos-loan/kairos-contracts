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

    function testMultipleRepay() public {
        Protocol storage proto = protocolStorage();

        vm.startPrank(signer);

        vm.warp(365 days);
        uint256[] memory uint256Array = new uint256[](2);
        uint256Array[0] = 1;
        uint256Array[1] = 2;

        uint tokenId1 =nft.mintOne();
        nft.transferFrom(signer, address(kairos), tokenId1);

        uint tokenId2 =nft.mintOne();

        nft.transferFrom(signer, address(kairos), tokenId2);
        Loan memory loan1 = getLoan1();
        Loan memory loan2 = getLoan2();

        loan1.borrower = signer;
        loan2.borrower = signer;
        store(loan1, 1);
        store(loan2, 2);

        uint256 toRepay = uint256(1 ether * 2 weeks).mul(proto.tranche[0]) + 1 ether;

        money.mint(toRepay);
        money.approve(address(kairos), toRepay);

        kairos.repay(uint256Array);
        console.log(signer);

        assertEq(nft.balanceOf(address(this)), 2);
        assertEq(money.balanceOf(address (this)),   100000000000000000000);
    }
}
