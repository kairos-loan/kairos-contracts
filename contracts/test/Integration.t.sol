// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./Commons/SetUp.sol";

/// @notice tests of entire loan lifecycles
contract TestIntegration is SetUp {
    using RayMath for Ray;
    using RayMath for uint256;

    function testSimpleLoan() public {
        // signer is the supplier
        uint256 thisInitialBalance = money.balanceOf(address(this));
        OfferArgs[] memory offerArgs = new OfferArgs[](1);
        offerArgs[0] = getOfferArgs(getOffer());
        vm.prank(signer);
        money.mint(1 ether);
        vm.prank(signer);
        money.approve(address(kairos), type(uint256).max);
        nft.safeTransferFrom(address(this), address(kairos), 1, abi.encode(offerArgs));
        assertEq(money.balanceOf(signer), 0);
        assertEq(money.balanceOf(address(this)), thisInitialBalance + 1 ether);
        assertEq(nft.ownerOf(1), address(kairos));
        skip(1 weeks);
        Ray tranche0Rate = kairos.getRateOfTranche(0);
        uint256 toRepay = uint256(1 ether).mul(tranche0Rate.mul(1 weeks)) + 1 ether;
        money.approve(address(kairos), toRepay);
        kairos.repay(oneInArray);
        assertEq(money.balanceOf(address(this)), thisInitialBalance + 1 ether - toRepay);
        vm.prank(signer);
        kairos.claim(oneInArray);
        assertEq(money.balanceOf(signer), toRepay);
    }
}
