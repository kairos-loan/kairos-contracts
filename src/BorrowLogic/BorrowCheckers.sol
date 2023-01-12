// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {Signature} from "../Signature.sol";
import {NFTokenUtils} from "../utils/NFTokenUtils.sol";
import {Offer, OfferArgs, NFToken} from "../../src/DataStructure/Objects.sol";
import {BadCollateral, OfferHasExpired, RequestedAmountTooHigh} from "../../src/DataStructure/Errors.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @notice handles checks to verify validity of a loan request
abstract contract BorrowCheckers is Signature {
    using NFTokenUtils for NFToken;

    /// @notice checks arguments validity for usage of one Offer
    /// @param args arguments for the Offer
    /// @return signer computed signer of `args.signature` according to `args.offer`
    function checkOfferArgs(OfferArgs memory args) internal view returns (address) {
        address signer = ECDSA.recover(offerDigest(args.offer), args.signature);

        if (block.timestamp > args.offer.expirationDate) {
            revert OfferHasExpired(args.offer, args.offer.expirationDate);
        }
        if (args.amount > args.offer.loanToValue) {
            revert RequestedAmountTooHigh(args.amount, args.offer.loanToValue);
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
