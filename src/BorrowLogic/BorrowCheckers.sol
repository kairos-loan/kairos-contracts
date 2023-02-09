// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import {IBorrowCheckers} from "../../interface/IBorrowCheckers.sol";

import {Signature} from "../Signature.sol";
import {NFTokenUtils} from "../utils/NFTokenUtils.sol";
import {Offer, OfferArg, NFToken} from "../../src/DataStructure/Objects.sol";
import {BadCollateral, OfferHasExpired, RequestedAmountTooHigh} from "../../src/DataStructure/Errors.sol";

/// @notice handles checks to verify validity of a loan request
abstract contract BorrowCheckers is IBorrowCheckers, Signature {
    using NFTokenUtils for NFToken;

    /// @notice checks arguments validity for usage of one Offer
    /// @param arg arguments for the Offer
    /// @return signer computed signer of `arg.signature` according to `arg.offer`
    function checkOfferArg(OfferArg memory arg) internal view returns (address) {
        address signer = ECDSA.recover(offerDigest(arg.offer), arg.signature);

        if (block.timestamp > arg.offer.expirationDate) {
            revert OfferHasExpired(arg.offer, arg.offer.expirationDate);
        }
        if (arg.amount > arg.offer.loanToValue) {
            revert RequestedAmountTooHigh(arg.amount, arg.offer.loanToValue, arg.offer);
        }

        return signer;
    }

    /// @notice checks collateral validity regarding the offer
    /// @param offer loan offer which validity should be checked for the provided collateral
    /// @param providedNft nft sent to be used as collateral
    function checkCollateral(Offer memory offer, NFToken memory providedNft) internal pure {
        if (!offer.collateral.eq(providedNft)) {
            revert BadCollateral(offer, providedNft);
        }
    }
}
