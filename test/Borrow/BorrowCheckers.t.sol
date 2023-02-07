// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {BadCollateral, OfferHasExpired, RequestedAmountTooHigh} from "../../src/DataStructure/Errors.sol";
import {Internal} from "../Commons/Internal.sol";
import {NFToken, Offer, OfferArg} from "../../src/DataStructure/Objects.sol";

contract TestBorrowCheckers is Internal {
    function testAddressRecovery() public {
        Offer memory offer;
        OfferArg memory args;

        offer.expirationDate = block.timestamp + 2 weeks;
        args.offer = offer;

        args.signature = getSignature(offer);

        assertEq(signer, checkOfferArg(args));
    }

    function testOfferHasExpired() public {
        Offer memory offer1;
        Offer memory offer2;
        OfferArg memory args1;
        OfferArg memory args2;

        offer1.expirationDate = block.timestamp + 2 weeks;
        args1.offer = offer1;
        args1.signature = getSignature(offer1);
        vm.warp(args1.offer.expirationDate - 1);
        checkOfferArg(args1);

        offer2.expirationDate = block.timestamp + 2 weeks;
        args2.offer = offer2;
        args2.signature = getSignature(offer2);
        vm.warp(args2.offer.expirationDate + 1);
        vm.expectRevert(
            abi.encodeWithSelector(OfferHasExpired.selector, args2.offer, args2.offer.expirationDate)
        );
        this.checkOfferArgExternal(args2);
    }

    function testAmount() public {
        OfferArg memory args;
        Offer memory offer;
        offer.loanToValue = 1 ether - 1;
        offer.expirationDate = block.timestamp + 2 weeks;
        args.offer = offer;
        args.amount = 1 ether;
        args.signature = getSignature(offer);
        vm.expectRevert(abi.encodeWithSelector(RequestedAmountTooHigh.selector, 1 ether, 1 ether - 1, offer));
        this.checkOfferArgExternal(args);
    }

    function testBadCollateral() public {
        Offer memory offer = getOffer();
        NFToken memory nft = NFToken({implem: nft, id: 2});
        vm.expectRevert(abi.encodeWithSelector(BadCollateral.selector, offer, nft));
        this.checkCollateralExternal(offer, nft);
    }
}
