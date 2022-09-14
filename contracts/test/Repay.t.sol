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
        nft.transferFrom(address(this), address(nftaclp), 1);
        IDCHelperFacet(address(nftaclp)).delegateCall(
            address(this), 
            abi.encodeWithSelector(this.setLoan.selector, money, nft, address(this)));
        uint256 toRepay = uint256(1 ether * 2 weeks).mul(proto.tranche[0]);
        vm.startPrank(signer);
        money.mint(toRepay);
        money.approve(address(nftaclp), toRepay);
        IRepayFacet(address(nftaclp)).repay(uint256Array);
        assertEq(nft.balanceOf(address(this)), 1);
        assertEq(money.balanceOf(signer), 0);
    }

    function setLoan(IERC20 _money, IERC721 _nft, address borrower) public {
        Protocol storage proto = protocolStorage();
        uint256[] memory uint256Array;
        proto.loan[1] = Loan({
            assetLent: _money,
            lent: 1 ether,
            shareLent: ONE,
            startDate: block.timestamp - 2 weeks,
            endDate: block.timestamp + 2 weeks,
            interestPerSecond: proto.tranche[0],
            borrower: borrower,
            collateral: _nft,
            tokenId: 1,
            repaid: 0,
            supplyPositionIds: uint256Array,
            borrowerClaimed: false,
            liquidated: false
        });
    }
}
