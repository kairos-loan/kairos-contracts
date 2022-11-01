// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./SetUp.sol";

contract TestRepay is SetUp {
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
/*
    function testOddRepay() public {
        uint toRepay;
        Protocol storage proto = protocolStorage();
        vm.warp(365 days);
        uint256[] memory uint256Array = new uint256[](10);
        for(uint i =0;i< uint256Array.length;i++){
            uint256Array[i] = i;
            nft.transferFrom(address(this), address(kairos), 1);
            Loan memory loan = getDefaultLoan();
            loan.borrower = address(this);
            store(loan, i);
            uint256 _toRepay = uint256(1 ether * 2 weeks).mul(proto.tranche[0]) + 1 ether;
            toRepay += _toRepay;
            vm.startPrank(signer);
            money.mint(toRepay);
            money.approve(address(kairos), toRepay);
            kairos.repay(uint256Array);
            assertEq(nft.balanceOf(address(kairos)), 1);
            assertEq(money.balanceOf(signer), 0);
        }

    }
    */
}
