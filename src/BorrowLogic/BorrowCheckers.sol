// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import {IBorrowCheckers} from "../interface/IBorrowCheckers.sol";

import {Signature} from "../Signature.sol";
import {NFTokenUtils} from "../utils/NFTokenUtils.sol";
import {Offer, OfferArg, NFToken} from "../../src/DataStructure/Objects.sol";
import {Protocol} from "../../src/DataStructure/Storage.sol";
import {protocolStorage} from "../../src/DataStructure/Global.sol";
// solhint-disable-next-line max-line-length
import {BadCollateral, OfferHasExpired, RequestedAmountTooHigh, RequestedAmountIsUnderMinimum, InvalidTranche} from "../../src/DataStructure/Errors.sol";

/// @notice handles checks to verify validity of a loan request
abstract contract BorrowCheckers is IBorrowCheckers, Signature {
    using NFTokenUtils for NFToken;

    /// @notice checks arguments validity for usage of one Offer
    /// @param arg arguments for the Offer
    /// @return signer computed signer of `arg.signature` according to `arg.offer`
    function checkOfferArg(OfferArg memory arg) internal view returns (address signer) {
        Protocol storage proto = protocolStorage();
        signer = ECDSA.recover(offerDigest(arg.offer), arg.signature);
        uint256 amountLowerBound = proto.offerBorrowAmountLowerBound[arg.offer.assetToLend];

        if (!(arg.amount > amountLowerBound)) {
            revert RequestedAmountIsUnderMinimum(arg.offer, arg.amount, amountLowerBound);
        }
        if (block.timestamp > arg.offer.expirationDate) {
            revert OfferHasExpired(arg.offer, arg.offer.expirationDate);
        }
        if (arg.offer.tranche >= proto.nbOfTranches) {
            revert InvalidTranche(proto.nbOfTranches);
        }
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
