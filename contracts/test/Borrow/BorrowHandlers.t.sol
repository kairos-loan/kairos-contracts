// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../Commons/Internal.sol";

contract TestBorrowHandlers is Internal {
    // useOffer tests
    function testConsistentAssetRequests() public {
        CollateralState memory collatState = getCollateralState();
        Offer memory offer = getOffer();
        offer.assetToLend = money2;
        OfferArgs memory offArgs = getOfferArg(offer);

        vm.expectRevert(abi.encodeWithSelector(InconsistentAssetRequests.selector, money, money2));
        this.useOfferExternal(offArgs, collatState);

        collatState.assetLent = money2;
        vm.mockCall(
            address(money2),
            abi.encodeWithSelector(IERC20.transferFrom.selector, signer, BORROWER, offArgs.amount),
            abi.encode(true)
        );
        this.useOfferExternal(offArgs, collatState);
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
