// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./SetUp.sol";

/// @notice tests of entire loan lifecycles
contract TestIntegration is SetUp {
    function testSimpleLoan() public {
        // signer is the supplier
        OfferArgs[] memory offerArgs = getOfferArgs(getOffer());
        vm.prank(signer);
        money.mint(1 ether);
        vm.prank(signer);
        money.approve(address(kairos), type(uint256).max);
        nft.safeTransferFrom(address(this), address(kairos), 1, abi.encode(offerArgs));
        skip(1 weeks);
        money.approve(address(kairos), type(uint256).max);
        uint256[] memory oneInArray = new uint256[](1);
        oneInArray[0] = 1;
        kairos.repay(oneInArray);
        vm.prank(signer);
        kairos.claim(oneInArray);
    }
}

// 7671232876712328 reimbursed
// 767123287671232  principal plus interests