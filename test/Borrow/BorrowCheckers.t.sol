// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../Commons/Internal.sol";

contract TestBorrowCheckers is Internal {
    function testAddressRecovery() public {
        Offer memory offer;
        OfferArgs memory args;

        offer.expirationDate = block.timestamp + 2 weeks;
        args.offer = offer;

        args.signature = getSignature(offer);

        assertEq(signer, checkOfferArgs(args));
    }

    function testOfferHasExpired() public {
        Offer memory offer1;
        Offer memory offer2;
        OfferArgs memory args1;
        OfferArgs memory args2;

        offer1.expirationDate = block.timestamp + 2 weeks;
        args1.offer = offer1;
        args1.signature = getSignature(offer1);
        vm.warp(args1.offer.expirationDate - 1);
        checkOfferArgs(args1);

        offer2.expirationDate = block.timestamp + 2 weeks;
        args2.offer = offer2;
        args2.signature = getSignature(offer2);
        vm.warp(args2.offer.expirationDate + 1);
        vm.expectRevert(
            abi.encodeWithSelector(OfferHasExpired.selector, args2.offer, args2.offer.expirationDate)
        );
        this.checkOfferArgsExternal(args2);
    }

    function testAmount() public {
        OfferArgs memory args;
        Offer memory offer;
        offer.loanToValue = 1 ether - 1;
        offer.expirationDate = block.timestamp + 2 weeks;
        args.offer = offer;
        args.amount = 1 ether;
        args.signature = getSignature(offer);
        vm.expectRevert(abi.encodeWithSelector(RequestedAmountTooHigh.selector, 1 ether, 1 ether - 1));
        this.checkOfferArgsExternal(args);
    }

    function testBadCollateral() public {
        Offer memory offer = getOffer();
        NFToken memory nft = NFToken({implem: nft, id: 2});
        vm.expectRevert(abi.encodeWithSelector(BadCollateral.selector, offer, nft));
        this.checkCollateralExternal(offer, nft);
    }
}
