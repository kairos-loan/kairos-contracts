// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {BadCollateral, OfferHasExpired, RequestedAmountTooHigh} from "../../src/DataStructure/Errors.sol";
import {Internal} from "../Commons/Internal.sol";
import {NFToken, Offer, OfferArg} from "../../src/DataStructure/Objects.sol";

contract TestBorrowCheckers is Internal {
    function testAddressRecovery() public {
        Offer memory offer;
        OfferArg memory arg;

        offer.expirationDate = block.timestamp + 2 weeks;
        arg.offer = offer;

        arg.signature = getSignature(offer);

        assertEq(signer, checkOfferArg(arg));
    }

    function testOfferHasExpired() public {
        Offer memory offer1;
        Offer memory offer2;
        OfferArg memory arg1;
        OfferArg memory arg2;

        offer1.expirationDate = block.timestamp + 2 weeks;
        arg1.offer = offer1;
        arg1.signature = getSignature(offer1);
        vm.warp(arg1.offer.expirationDate - 1);
        checkOfferArg(arg1);

        offer2.expirationDate = block.timestamp + 2 weeks;
        arg2.offer = offer2;
        arg2.signature = getSignature(offer2);
        vm.warp(arg2.offer.expirationDate + 1);
        vm.expectRevert(
            abi.encodeWithSelector(OfferHasExpired.selector, arg2.offer, arg2.offer.expirationDate)
        );
        this.checkOfferArgExternal(arg2);
    }

    function testAmount() public {
        OfferArg memory arg;
        Offer memory offer;
        offer.loanToValue = 1 ether - 1;
        offer.expirationDate = block.timestamp + 2 weeks;
        arg.offer = offer;
        arg.amount = 1 ether;
        arg.signature = getSignature(offer);
        vm.expectRevert(abi.encodeWithSelector(RequestedAmountTooHigh.selector, 1 ether, 1 ether - 1, offer));
        this.checkOfferArgExternal(arg);
    }

    function testBadCollateral() public {
        Offer memory offer = getOffer();
        NFToken memory nft = NFToken({implem: nft, id: 2});
        vm.expectRevert(abi.encodeWithSelector(BadCollateral.selector, offer, nft));
        this.checkCollateralExternal(offer, nft);
    }
}
