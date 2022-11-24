// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../Commons/Internal.sol";

contract TestBorrowHandlers is Internal {
    // useOffer tests
    function testConsistentAssetRequests() public {
        CollateralState memory collatState;
        Offer memory offer = getOffer();
        offer.assetToLend = money;

        vm.mockCall(
            address(money),
            abi.encodeWithSelector(IERC20.transferFrom.selector, signer, address(0), uint256(0)),
            abi.encode(true)
        );
        vm.expectRevert(
            abi.encodeWithSelector(InconsistentAssetRequests.selector, IERC20(address(0)), money)
        );
        this.useOfferExternal(getOfferArgs(offer), collatState);

        collatState.assetLent = money;
        vm.mockCall(
            address(money),
            abi.encodeWithSelector(IERC20.transferFrom.selector, signer, address(0), uint256(0)),
            abi.encode(true)
        );
        this.useOfferExternal(getOfferArgs(offer), collatState);
        assertEq(supplyPositionStorage().totalSupply, 1);
    }

    // function testRequestAmountCheckAndAssetTransfer() public {
    //     CollateralState memory collatState;
    //     collatState.assetLent = money;
    //     // OfferArgs memory args = getOfferArgs(getOffer());
    //     // args.amount = 1 ether;
    //     // todo #28 finish TestBorrowHandlers
    // }
}
