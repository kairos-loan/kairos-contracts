// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../../BorrowLogic/BorrowHandlers.sol";
import "./InternalBorrowTestCommons.sol";

contract TestBorrowHandlers is InternalBorrowTestCommons, BorrowHandlers {
    // useOffer tests

    function testConsistentAssetRequests() public {
        CollateralState memory collatState;

        vm.mockCall(
            address(MOCK_TOKEN),
            abi.encodeWithSelector(IERC20.transferFrom.selector, signer, address(0), uint256(0)),
            abi.encode(true)
        );
        vm.expectRevert(abi.encodeWithSelector(InconsistentAssetRequests.selector, IERC20(address(0)), MOCK_TOKEN));
        this.useOfferExternal(getOfferArgs(), collatState);

        collatState.assetLent = MOCK_TOKEN;
        vm.mockCall(
            address(MOCK_TOKEN),
            abi.encodeWithSelector(IERC20.transferFrom.selector, signer, address(0), uint256(0)),
            abi.encode(true)
        );
        this.useOfferExternal(getOfferArgs(), collatState);
        assertEq(supplyPositionStorage().totalSupply, 1);
    }

    function testRequestAmountCheckAndAssetTransfer() public {
        CollateralState memory collatState;
        collatState.assetLent = MOCK_TOKEN;
        OfferArgs memory args = getOfferArgs();
        args.amount = 1 ether;
        // not finished
    }

    // helpers todo #10 move helpers to dedicated file

    function useOfferExternal(
        OfferArgs memory args,
        CollateralState memory collatState
    ) public returns (CollateralState memory) {
        return useOffer(args, collatState);
    }

    function getOfferArgs() private returns (OfferArgs memory ret) {
        Offer memory offer;
        FloorSpec memory specs;
        offer.assetToLend = MOCK_TOKEN;
        offer.collatSpecs = abi.encode(specs);
        offer.loanToValue = 1 ether;
        offer.expirationDate = block.timestamp + 2 weeks;
        Root memory root = Root({root: keccak256(abi.encode(offer))});
        ret.offer = offer;
        ret.root = root;
        ret.signature = getSignatureInternal(root);
    }
}
