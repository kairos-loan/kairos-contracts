// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./TestCommons.sol";
import "../RepayFacet.sol";

contract TestRepay is TestCommons, RepayFacet {
    function testSimpleRepay() public {
        Protocol storage proto = protocolStorage();
        uint256[] memory uint256Array = new uint256[](1);
        address borrower = address(0xbabe);
        address caller = address(0xca11);
        IERC20 assetLent = IERC20(address(0xc0ffee));
        uint256Array[0] = 1;

        vm.warp(365 days);

        proto.loan[1] = Loan({
            assetLent: assetLent,
            lent: 1 ether,
            startDate: block.timestamp - 2 weeks,
            endDate: block.timestamp + 2 weeks,
            interestPerSecond: proto.tranche[0],
            borrower: borrower,
            collateral: nft,
            tokenId: 1,
            repaid: 0,
            supplyPositionIds: uint256Array
        });

        // vm.mockCall(
        //     address(assetLent),
        //     abi.encodeWithSelector(IERC20.transferFrom, address(this)), null);
        vm.prank(borrower);
        this.repay(uint256Array);

        
    }
}