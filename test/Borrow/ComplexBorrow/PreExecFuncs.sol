// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {BorrowArg, NFToken, Offer, OfferArg} from "../../../src/DataStructure/Objects.sol";
import {External} from "../../Commons/External.sol";
import {NFT} from "../../../src/mock/NFT.sol";

struct ComplexBorrowData {
    BorrowArg bargs1;
    BorrowArg bargs2;
    OfferArg oargs1;
    OfferArg oargs2;
    OfferArg oargs3;
    Offer signer1Offer1;
    Offer signer1Offer2;
    Offer signer2Offer;
    uint256 m1InitialBalance;
    uint256 m2InitialBalance;
}

contract ComplexBorrowPreExecFuncs is External {
    function initOfferArgs(ComplexBorrowData memory d) internal returns (ComplexBorrowData memory) {
        d.oargs1 = OfferArg({
            signature: getSignature(d.signer1Offer1),
            amount: 1 ether / 2, // 25%
            offer: d.signer1Offer1
        });
        d.oargs2 = OfferArg({
            signature: getSignature2(d.signer2Offer),
            amount: 3 ether / 4, // 75%
            offer: d.signer2Offer
        });
        d.oargs3 = OfferArg({
            signature: getSignature(d.signer1Offer2),
            amount: 1 ether, // 50%
            offer: d.signer1Offer2
        });

        return d;
    }

    function initOffers(ComplexBorrowData memory d) internal view returns (ComplexBorrowData memory) {
        d.signer1Offer1 = Offer({
            assetToLend: money,
            loanToValue: 2 ether,
            duration: 2 weeks,
            expirationDate: block.timestamp + 1,
            tranche: 0,
            collateral: NFToken({implem: nft, id: 1})
        });
        d.signer1Offer2 = Offer({
            assetToLend: money2,
            loanToValue: 2 ether,
            duration: 4 weeks,
            expirationDate: block.timestamp + 1 days,
            tranche: 0,
            collateral: NFToken({implem: nft2, id: 1})
        });

        d.signer2Offer = Offer({
            assetToLend: money,
            loanToValue: 1 ether,
            duration: 1 weeks,
            expirationDate: block.timestamp + 1 hours,
            tranche: 0,
            collateral: NFToken({implem: nft, id: 1})
        });

        return d;
    }

    function initBorrowArgs(ComplexBorrowData memory d) internal view returns (ComplexBorrowData memory) {
        OfferArg[] memory offerArgs1 = new OfferArg[](2);
        offerArgs1[0] = d.oargs1;
        offerArgs1[1] = d.oargs2;
        OfferArg[] memory offerArgs2 = new OfferArg[](1);
        offerArgs2[0] = d.oargs3;

        d.bargs1 = BorrowArg({nft: NFToken({implem: nft, id: 1}), args: offerArgs1});

        d.bargs2 = BorrowArg({nft: NFToken({implem: nft2, id: 1}), args: offerArgs2});

        return d;
    }
}
