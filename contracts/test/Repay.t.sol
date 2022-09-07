// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "./TestCommons.sol";
import "../RepayFacet.sol";

contract TestRepay is TestCommons, RepayFacet {
    using RayMath for Ray;

    function testSimpleRepay() public {
        Protocol storage proto = protocolStorage();
        uint256[] memory uint256Array = new uint256[](1);
        address borrower = address(0xbabe);
        address caller = address(0xca11);
        IERC20 assetLent = IERC20(address(0xc0ffee));
        IERC721 mockNFT = IERC721(address(0xabba));
        uint256Array[0] = 1;
        bytes memory empty;
        bytes memory randoCode = hex"01";

        vm.etch(address(assetLent), randoCode);
        vm.warp(365 days);

        proto.loan[1] = Loan({
            assetLent: assetLent,
            lent: 1 ether,
            startDate: block.timestamp - 2 weeks,
            endDate: block.timestamp + 2 weeks,
            interestPerSecond: proto.tranche[0],
            borrower: borrower,
            collateral: mockNFT,
            tokenId: 1,
            repaid: 0,
            supplyPositionIds: uint256Array
        });

        vm.mockCall(
            address(assetLent),
            abi.encodeWithSelector(
                IERC20.transferFrom.selector, 
                caller, 
                address(this),
                ONE.div(10).mul(4).div(365 days).mul(2 weeks).mul(1 ether)
            ), 
            empty
        );
        vm.mockCall(
            address(mockNFT),
            abi.encodeWithSelector(
                erc721SafeTransferFromSelector,
                address(this),
                borrower,
                1
            ), 
            empty
        );
        vm.prank(caller);
        this.repay(uint256Array);
    }
}