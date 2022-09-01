// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../../BorrowLogic/BorrowHandlers.sol";
import "./InternalBorrowTestCommons.sol";

// import "forge-std/Test.sol";

contract TestBorrowHandlers is InternalBorrowTestCommons, BorrowHandlers {
    // useOffer tests

    function testConsistentAssetRequests() public {
        CollateralState memory collatState;
        vm.mockCall(
            address(MOCK_TOKEN), 
            abi.encodeWithSelector(
                IERC20.transferFrom.selector,
                signer, address(0), uint256(0)),
            abi.encode(true));
        vm.expectRevert(abi.encodeWithSelector(
            InconsistentAssetRequests.selector, IERC20(address(0)), MOCK_TOKEN));
        this.useOfferExternal(getOfferArgs(), collatState);

        collatState.assetLent = MOCK_TOKEN;
        vm.mockCall(
            address(MOCK_TOKEN), 
            abi.encodeWithSelector(
                IERC20.transferFrom.selector,
                signer, address(0), uint256(0)),
            abi.encode(true));
        vm.mockCall(
            address(this), 
            abi.encodeWithSelector(
                SupplyPositionFacet.safeMint.selector,
                signer, Provision({
                    amount: uint256(0),
                    share: Ray.wrap(0)
                })),
            abi.encode(uint256(1)));
        this.useOfferExternal(getOfferArgs(), collatState);
    }

    // helpers

    function useOfferExternal(
        OfferArgs memory args,
        CollateralState memory collatState
    ) public returns(
        uint256 supplyPositionId, 
        CollateralState memory
    ) {
        return useOffer(args, collatState);
    }

    function getOfferArgs() private returns(OfferArgs memory ret) {
        Offer memory offer;
        FloorSpec memory specs;
        offer.assetToLend = MOCK_TOKEN;
        offer.collatSpecs = abi.encode(specs);
        offer.loanToValue = 1 ether;
        Root memory root = Root({root: keccak256(abi.encode(offer))});
        ret.offer = offer;
        ret.root = root;
        ret.signature = getSignature(root);
    }
}

