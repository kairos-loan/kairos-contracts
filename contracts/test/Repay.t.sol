// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./Commons/External.sol";

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
        Protocol storage proto = protocolStorage();
        vm.warp(365 days);
        uint256[] memory loanIds = new uint256[](nbOfRepays);
        uint256 toRepay = nbOfRepays * (uint256(1 ether * 2 weeks).mul(proto.tranche[0]) + 1 ether);

        for (uint8 i; i < nbOfRepays; i++) {
            loanIds[i] = i + 1;
            nft.mintOne();
            nft.transferFrom(address(this), address(kairos), i + 2);
            Loan memory loan = getLoan();
            loan.borrower = address(this);
            loan.collateral.id = 2 + i;
            store(loan, i + 1);
        }

        vm.startPrank(signer);
        money.mint(toRepay);
        money.approve(address(kairos), toRepay);
        kairos.repay(loanIds);

        assertEq(nft.balanceOf(address(this)), 1 + nbOfRepays);
        assertEq(money.balanceOf(signer), 0);
    }
}
