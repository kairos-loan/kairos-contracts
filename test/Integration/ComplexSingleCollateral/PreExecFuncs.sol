// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {BorrowArgs, NFToken, Offer, OfferArgs} from "../../../src/DataStructure/Objects.sol";
import {External} from "../../Commons/External.sol";

struct BorrowData {
    BorrowArgs bargs;
    OfferArgs oargs1;
    OfferArgs oargs2;
    Offer signer1Offer;
    Offer signer2Offer;
}

contract SingleCollatPreExecFuncs is External {
    function initOfferArgs(
        BorrowData memory d,
        uint256 oargs1Amount,
        uint256 oargs2Amount
    ) internal returns (BorrowData memory) {
        d.oargs1 = OfferArgs({
            signature: getSignature(d.signer1Offer),
            amount: oargs1Amount,
            offer: d.signer1Offer
        });
        d.oargs2 = OfferArgs({
            signature: getSignature2(d.signer2Offer),
            amount: oargs2Amount,
            offer: d.signer2Offer
        });
        return d;
    }

    function initOffers(
        BorrowData memory d,
        uint256 ltv1,
        uint256 ltv2
    ) internal view returns (BorrowData memory) {
        d.signer1Offer = Offer({
            assetToLend: money,
            loanToValue: ltv1,
            duration: 4 weeks,
            expirationDate: block.timestamp + 1 hours,
            tranche: 0,
            collateral: NFToken({implem: nft, id: 1})
        });

        d.signer2Offer = Offer({
            assetToLend: money,
            loanToValue: ltv2,
            duration: 4 weeks,
            expirationDate: block.timestamp + 1 hours,
            tranche: 0,
            collateral: NFToken({implem: nft, id: 1})
        });

        return d;
    }

    function initBorrowArgs(BorrowData memory d) internal view returns (BorrowData memory) {
        OfferArgs[] memory offerArgs1 = new OfferArgs[](2);
        offerArgs1[0] = d.oargs1;
        offerArgs1[1] = d.oargs2;

        d.bargs = BorrowArgs({nft: NFToken({implem: nft, id: 1}), args: offerArgs1});

        return d;
    }
}
